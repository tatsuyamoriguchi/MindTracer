//
//  HomeView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: MindStateStore
    
    @StateObject private var mindStateManager = HealthKitMindStateManager()
    @State private var summary: MindStateSummary?
    @State private var wisdomMessage: String = "Loading..."
    @State var showEntrySheet = false
    @State private var pulse: Bool = false
    @State private var showSnapshotInfo: Bool = false
    
    private var currentSummary: MindStateSummary? {
        let recentEntries = Array(store.entries.suffix(5)) // only last 5 entries
        return MindStateAnalysisEngine.summarize(recentEntries)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                content
                
                if let summary = currentSummary {
                    ZStack {
                        
                        // White glow background for visibility
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 280, height: 280)
                            .blur(radius: 30)
                        
                        // Flaring layer
#if targetEnvironment(simulator)
                        let recentEntries = Array(store.entries.suffix(5)) // use test data
#else
                        let recentEntries = Array(mindStateManager.allEntries.suffix(5))
#endif
//                        let _ = print("Recent entries count:", recentEntries.count) // debug
                        let dominantFeeling = MindStateAnalysisEngine.calculateDominantFeeling(from: recentEntries) ?? .neutral
//                        let _ = print("Dominant feeling:", dominantFeeling.rawValue)
                        let trend = MindStateAnalysisEngine.calculateTrend(from: recentEntries)
                        let trendOpacity = trend.opacity * 2.5
                        
                        Circle()
                            .fill(dominantFeeling.baseColor.opacity(trendOpacity))
                            .frame(width: 230, height: 230)
                            .scaleEffect(pulse ? 1.3 : 1.0)
                            .opacity(pulse ? 0.2 : 0.5)
                            .blur(radius: 10)
                        
                        // Big circle: dominant feeling + trend-based opacity
                        Circle()
                            .fill(dominantFeeling.baseColor)
                            .opacity(pulse ? 0.2 : 0.5)
                            .frame(width: 200, height: 200)
                            .shadow(radius: 5)
                            .padding()
                        
                        // Small circle: latest feeling, full opacity
                        if let latest = summary.latestEntry,
                           let latestFeeling = latest.feelings.first {
                            Circle()
                                .fill(latestFeeling.baseColor)  // always full color
                                .frame(width: 80, height: 80)
                                .shadow(radius: 5)
                        }
                        
                        // Latest Mind text on top of the circle
                        if let latest = summary.latestEntry {
                            Text("Latest Feeling: \n\(latest.feelings.first?.rawValue.capitalized ?? "Unknown")")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                    }
                    .task {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            pulse.toggle()
                        }
                    }
                    // Latest analysis summary
                    Text(summary.summaryText)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)   // let it expand horizontally
                        .fixedSize(horizontal: false, vertical: true) // prevent truncation vertically
                        .padding()
                    
                    
                    
                } else {
                    Text("Fetching mind state...")
                        .font(.headline)
                }
                
                // Words of Wisdom
                Text(wisdomMessage)
                    .italic()
                    .padding()
                    .foregroundColor(.blue)
                
                // Simulator notice
#if targetEnvironment(simulator)
                Text("This is a sample since you're using a simulator.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
#endif
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Mind Tracer")
            .background(Color(.systemBackground))
            .ignoresSafeArea()
            .padding()
            .task {
                await loadData()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showEntrySheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showEntrySheet) {
                MindStateEntryFlow(showEntrySheet: $showEntrySheet)
            }
            .preferredColorScheme(.dark)
            .task {
#if targetEnvironment(simulator)
                let recentEntries = Array(store.entries.suffix(5))
                for entry in recentEntries {
                    print("Timestamp:", entry.timestamp)
                    print("Valence:", entry.valence)
                    print("Feelings:", entry.feelings.map { $0.rawValue })
                    print("Location:", entry.locationName ?? "nil")
                    print("---")
                }
#endif
            }
            
        }
        .padding()
        .sheet(isPresented: $showSnapshotInfo) {
            VStack(spacing: 20) {
                Text("Mind Snapshot Explanation")
                    .font(.headline)
                
                ScrollView {
                    Text("""
                        • Big Circle: Shows your overall mood from your recent entries. Its color reflects your dominant feeling (yellow = happy, orange = excited, gray = neutral). The pulse and glow represent how your mood is trending.
                        
                        • Flare / Glow: The surrounding glow pulses gently. Brighter pulses indicate stronger mood trends, rising or falling.
                        
                        • Small Circle: Shows your latest recorded mood. Its color matches the feeling you just recorded.
                        
                        • Summary Text: Describes your recent mood in words, including your latest feeling, often felt emotions over recent entries, and trend direction.
                        """)
                    .padding()
                    .multilineTextAlignment(.leading)
                }
                
                Button("Close") {
                    showSnapshotInfo = false
                }
                .font(.headline)
                .padding()
            }
            .padding()
        }
    }
    
    private var content: some View {
        HStack(spacing: 16) {
            Text("Mind Snapshot")
                .font(.title2)
                .fontWeight(.semibold)
            Button(action: {
                showSnapshotInfo.toggle()
            }) {
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .help("Tap for explanation") // optional tooltip in macOS / iPad
            
        }
        .padding()
    }
}

extension HomeView {
    
    @MainActor
    private func loadData() async {
        
#if !targetEnvironment(simulator)
        do {
            try await mindStateManager.requestAuthorization()
        } catch {
            withAnimation {
                self.summary = nil
                self.wisdomMessage = "Health data access was not granted."
            }
            return
        }
#endif
        
        await mindStateManager.fetchLatestMindState()
        
        let computedSummary = MindStateAnalysisEngine.summarize(store.entries)
        
        withAnimation(.easeInOut(duration: 0.6)) {
            self.summary = computedSummary
            self.wisdomMessage = WordsOfWisdomEngine.wisdom(for: computedSummary.latestEntry)
        }
    }
    
    
}

#Preview {
    HomeView()
}

