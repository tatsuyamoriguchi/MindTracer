//
//  AnalysisView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/17/25.
//

import Foundation
import SwiftUI
import Charts

struct AnalysisView: View {
    
    @State private var selectedTimeRange: AnalysisTimeRange = .past7Days
    @State private var selectedKind: MindStateKind? = nil       // nil = All
    @State private var selectedLocationID: String? = nil        // nil = All
    @State private var selectedContext: MindContext? = nil      // nil = All
    
    @EnvironmentObject var store: MindStateStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                
                // MARK: - Time Range Picker
                Text("Select Time Range")
                    .font(.headline)
                    .padding(.horizontal)
                
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(AnalysisTimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // MARK: - Summary Info
                VStack(spacing: 8) {
                    Text("Total entries: \(store.entries.count)")
                    let dates = store.entries.map { $0.timestamp }.sorted()
                    Text("Oldest: \(dates.first?.formatted() ?? "-")")
                    Text("Newest: \(dates.last?.formatted() ?? "-")")
                }
                .padding(.horizontal)
                
                // MARK: - Chart
                valenceLineChart
            }
        }
        .navigationTitle("Analysis")
        .onAppear {
#if DEBUG
            // Generate test data in DEBUG mode if only today's entries exist
            if store.entries.allSatisfy({ Calendar.current.isDateInToday($0.timestamp) }) {
                store.generateTestEntries(days: 180)
            }
#endif
        }
    }
    
    // MARK: - Filtered & Aggregated Points
    private var filteredAndAggregatedPoints: [ValencePoint] {
        let filtered = filteredEntries(from: store.entries, range: selectedTimeRange)
        return aggregateEntries(filtered, for: selectedTimeRange)
    }
    
 
    private func filteredEntries(from entries: [MindStateEntry], range: AnalysisTimeRange) -> [MindStateEntry] {
        let now = Date()
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current   // ensure local time zone

        // Compute the start date for the selected range, aligned to calendar days
        let startDate: Date? = {
            switch range {
            case .past8Hours:
                return calendar.date(byAdding: .hour, value: -8, to: now)
            case .past3Days:
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -3, to: now)!)
            case .past7Days:
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -7, to: now)!)
            case .past30Days:
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -30, to: now)!)
            case .past90Days:
                return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -90, to: now)!)
            case .pastYear:
                return calendar.startOfDay(for: calendar.date(byAdding: .year, value: -1, to: now)!)
            case .all:
                return nil
            }
        }()

        
        // Debug
//        if range == .past8Hours {
//            for entry in entries {
//                print("ENTRY:", entry.timestamp,
//                      " startOfDay:", calendar.startOfDay(for: now),
//                      " passes:", entry.timestamp >= calendar.startOfDay(for: now))
//            }
//        }
        if range == .past8Hours {
            print("START DATE:", startDate!)
            for entry in entries {
                print("ENTRY:", entry.timestamp,
                      " passes:", entry.timestamp >= startDate!)
            }
        }

        
        // Filter entries based on startDate and user-selected filters
        return entries
            .filter { entry in
                // Convert UTC timestamp to local time for filtering
//                let localTimestamp = entry.timestamp.addingTimeInterval(TimeInterval(TimeZone.current.secondsFromGMT(for: entry.timestamp)))
//                return startDate == nil || localTimestamp >= startDate!
                return startDate == nil || entry.timestamp >= startDate!
            }
            .filter { entry in selectedKind == nil || entry.kind == selectedKind }
            .filter { entry in selectedLocationID == nil || entry.location?.roundedKey == selectedLocationID }
            .filter { entry in selectedContext == nil || entry.contexts.contains(selectedContext!) }
            .sorted { $0.timestamp < $1.timestamp }
    }

    // MARK: - Aggregation
    private func aggregateEntries(_ entries: [MindStateEntry], for range: AnalysisTimeRange) -> [ValencePoint] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        switch range {
        case .past8Hours:
            // Hourly aggregation
            let grouped = Dictionary(grouping: entries) { entry in
                calendar.dateInterval(of: .hour, for: entry.timestamp)!.start
            }
            return grouped.compactMap { date, entries in
                let avgValence = entries.map(\.valence).reduce(0, +) / Double(entries.count)
                return ValencePoint(date: date, valence: avgValence)
            }.sorted { $0.date < $1.date }
            
        default:
            // Daily aggregation
            let grouped = Dictionary(grouping: entries) { entry in
                calendar.startOfDay(for: entry.timestamp)
            }
            return grouped.compactMap { date, entries in
                let avgValence = entries.map(\.valence).reduce(0, +) / Double(entries.count)
                return ValencePoint(date: date, valence: avgValence)
            }.sorted { $0.date < $1.date }
        }
    }
    
    // MARK: - Chart View
    private var valenceLineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Valence Over Time")
                .font(.headline)
            
            // DEBUG
//            let _ = print("VALENCE POINTS:", filteredAndAggregatedPoints)

            if filteredAndAggregatedPoints.isEmpty {
                ContentUnavailableView(
                    "No Data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("No entries match the selected filters.")
                )
            } else {
                Chart(filteredAndAggregatedPoints) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value("Valence", point.valence)
                    )
                    PointMark(
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
    
    // MARK: - X Axis
    private var xAxisTickCount: Int {
        switch selectedTimeRange {
        case .past8Hours: return 8
        default: return 8
        }
    }
    
    private func xAxisLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        switch selectedTimeRange {
        case .past8Hours: formatter.dateFormat = "HH:mm"
        case .past3Days, .past7Days, .past30Days, .past90Days: formatter.dateFormat = "MMM d"
        case .pastYear, .all: formatter.dateFormat = "MMM yyyy"
        }
        return formatter.string(from: date)
    }
}
