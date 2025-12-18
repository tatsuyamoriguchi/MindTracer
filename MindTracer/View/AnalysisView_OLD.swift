//
//  AnalysisView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI
import Charts

struct AnalysisView_OLD: View {

    @State private var selectedTimeRange: AnalysisTimeRange = .past7Days
    @State private var selectedKind: MindStateKind? = nil // nil = All
    @State private var selectedLocationID: String? = nil // Use location.id ("lat,long") or nil for all
    @State private var selectedContext: MindContext? = nil // nil = All
    
    @EnvironmentObject var store: MindStateStore


    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Select Time Range")
                    .font(.headline)
                    .padding(.horizontal)

                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(AnalysisTimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented) // iOS 18 style
                .padding(.horizontal)
            }

            
            VStack(spacing: 16) {
                Text("Total entries: \(store.entries.count)")
                let dates = store.entries.map { $0.timestamp }.sorted()
                Text("Oldest: \(dates.first?.formatted() ?? "-")")
                Text("Newest: \(dates.last?.formatted() ?? "-")")


                // Filters go here later 👈

                valenceLineChart
            }
        }
        .navigationTitle("Analysis")
        .onAppear {
#if DEBUG
            if store.entries.allSatisfy({ Calendar.current.isDateInToday($0.timestamp) }) {
                store.generateTestEntries(days: 180)
            }
#endif
        }
        

    }

    private var filteredAndAggregatedPoints: [ValencePoint] {
        let filtered = filteredEntries(from: store.entries, range: selectedTimeRange)
        return aggregateEntries(filtered, for: selectedTimeRange)
    }
    
    private func aggregateEntries(_ entries: [MindStateEntry], for range: AnalysisTimeRange) -> [ValencePoint] {
        let calendar = Calendar.current

        switch range {
        case .today:
            // Hourly aggregation
            let grouped = Dictionary(grouping: entries) { entry in
                calendar.date(
                    bySettingHour: calendar.component(.hour, from: entry.timestamp),
                    minute: 0,
                    second: 0,
                    of: entry.timestamp
                )!
            }
            return grouped.compactMap { date, entries in
                let avgValence = entries.map { $0.valence }.reduce(0, +) / Double(entries.count)
                return ValencePoint(date: date, valence: avgValence)
            }
            .sorted { $0.date < $1.date }

        default:
            // Daily aggregation for longer ranges
            let grouped = Dictionary(grouping: entries) { entry in
                calendar.startOfDay(for: entry.timestamp)
            }
            return grouped.compactMap { date, entries in
                let avgValence = entries.map { $0.valence }.reduce(0, +) / Double(entries.count)
                return ValencePoint(date: date, valence: avgValence)
            }
            .sorted { $0.date < $1.date }
        }
    }

    

    
    private func filteredEntries(
        from entries: [MindStateEntry], range: AnalysisTimeRange
    ) -> [MindStateEntry] {

        let now = Date()

        let startDate: Date? = {
            switch selectedTimeRange {
            case .today:
                return Calendar.current.startOfDay(for: now)
            case .past3Days:
                return Calendar.current.date(byAdding: .day, value: -3, to: now)
            case .past7Days:
                return Calendar.current.date(byAdding: .day, value: -7, to: now)
            case .past30Days:
                return Calendar.current.date(byAdding: .day, value: -30, to: now)
            case .past90Days:
                return Calendar.current.date(byAdding: .day, value: -90, to: now)
            case .pastYear:
                return Calendar.current.date(byAdding: .year, value: -1, to: now)
            case .all:
                return nil
            }
        }()

        return entries
            .filter { entry in
                if let startDate {
                    entry.timestamp >= startDate
                } else {
                    true
                }
            }
            .filter { entry in
                selectedKind == nil || entry.kind == selectedKind
            }
            .filter { entry in
                selectedLocationID == nil || entry.location?.roundedKey == selectedLocationID
            }
            .filter { entry in
                selectedContext == nil || entry.contexts.contains(selectedContext!)
            }
            .sorted { $0.timestamp < $1.timestamp }
    }

    private func valencePoints(from entries: [MindStateEntry]) -> [ValencePoint] {
        entries.map {
            ValencePoint(date: $0.timestamp, valence: $0.valence)
        }
    }
    
    private var chartPoints: [ValencePoint] {
        valencePoints(
            from: filteredEntries(from: store.entries, range: selectedTimeRange)
        )
    }
    
    private func aggregateEntriesPerDay(_ entries: [MindStateEntry]) -> [ValencePoint] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.timestamp)
        }

        return grouped.compactMap { date, entries in
            let avgValence = entries.map { $0.valence }.reduce(0, +) / Double(entries.count)
            return ValencePoint(date: date, valence: avgValence)
        }
        .sorted { $0.date < $1.date }
    }

    
    private var valenceLineChart: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Valence Over Time")
                .font(.headline)

            if chartPoints.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("No entries match the selected filters.")
                )
            } else {
                Chart(aggregateEntriesPerDay(filteredEntries(from: store.entries, range: selectedTimeRange))) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Valence", point.valence)
                    )
                }
                .chartYScale(domain: -1...1)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: xAxisTickCount)) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(xAxisLabel(for: date))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 260)
            }
        }
        .padding()
    }
    
    private var xAxisTickCount: Int {
        switch selectedTimeRange {
        case .today: return 6
        case .past3Days: return 6
        case .past7Days: return 7
        case .past30Days: return 6
        case .past90Days: return 6
        case .pastYear: return 6
        case .all: return 6
        }
    }
    
    private func xAxisLabel(for date: Date) -> String {
        let formatter = DateFormatter()

        switch selectedTimeRange {
        case .today:
            formatter.dateFormat = "HH:mm"
        case .past3Days, .past7Days:
            formatter.dateFormat = "MMM d"
        case .past30Days, .past90Days:
            formatter.dateFormat = "MMM d"
        case .pastYear, .all:
            formatter.dateFormat = "MMM yyyy"
        }

        return formatter.string(from: date)
    }
}
