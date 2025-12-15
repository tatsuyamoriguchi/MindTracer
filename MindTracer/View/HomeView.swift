//
//  HomeView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var mindStateManager = HealthKitMindStateManager()
    
    @State private var summary: MindStateSummary?
    @State private var wisdomMessage: String = "Loading..."
    @State private var showEntrySheet = false

    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Latest analysis summary
                if let summary {
                    Text(summary.summaryText)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    if let latest = summary.latestEntry {
                        Text("Latest feeling: \(latest.feelings.first?.rawValue ?? "Unknown")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Fetching mind state...")
                        .font(.headline)
                }
                
                // Words of Wisdom
                Text(wisdomMessage)
                    .italic()
                    .padding()
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .navigationTitle("Mind Tracer")
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
                MindStateEntryFlow()
            }
        }
    }
}

extension HomeView {
    
    @MainActor
    private func loadData() async {
        #if targetEnvironment(simulator)
        // Simulator: skip HealthKit authorization
        await mindStateManager.fetchLatestMindState()
        
        let computedSummary = MindStateAnalysisEngine.summarize(mindStateManager.allEntries)
        self.summary = computedSummary
        self.wisdomMessage = WordsOfWisdomEngine.wisdom(for: computedSummary.latestEntry)
        
        #else
        // Real device
        do {
            try await mindStateManager.requestAuthorization()
            await mindStateManager.fetchLatestMindState()
            
            let computedSummary = MindStateAnalysisEngine.summarize(mindStateManager.allEntries)
            self.summary = computedSummary
            self.wisdomMessage = WordsOfWisdomEngine.wisdom(for: computedSummary.latestEntry)
            
        } catch {
            self.summary = nil
            self.wisdomMessage = "Unable to fetch mind state."
            print("HealthKit error:", error)
        }
        #endif
    }
}

#Preview {
    HomeView()
}

