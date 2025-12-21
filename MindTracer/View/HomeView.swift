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
    @State var showEntrySheet = false
    @State private var displayedColor: Color = .gray
    @State private var pulse: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                content
                
                if let summary {
                    ZStack {
                        // White glow background for visibility
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 280, height: 280)
                            .blur(radius: 30)
                        
                        // Flaring layer
                        Circle()
                            .fill(MindStateAnalysisEngine.colorForRecentTrend(from: mindStateManager.allEntries))
                            .frame(width: 230, height: 230)
                            .scaleEffect(pulse ? 1.3 : 1.0)
                            .opacity(pulse ? 0.2 : 0.5)
                            .blur(radius: 10)
                        
                        // Main circle
                        Circle()
                            .fill(MindStateAnalysisEngine.colorForRecentTrend(from: mindStateManager.allEntries))
                            .frame(width: 200, height: 200)
                            .shadow(radius: 5)
                            .padding()
//                            .animation(.easeInOut(duration: 4.0), value: mindStateManager.allEntries)
                        // Latest Mind text on top of the circle
                        if let latest = summary.latestEntry {
                            Text("Latest Feeling: \n\(latest.feelings.first?.rawValue ?? "Unknown")")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
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
        }
    }
    
    private var content: some View {
        VStack(spacing: 16) {
            Text("Mind Snapshot")
                .font(.title2)
                .fontWeight(.semibold)
            
        }
        .padding()
    }
}

extension HomeView {
    
    @MainActor
    private func loadData() async {
#if targetEnvironment(simulator)
        // Simulator: skip HealthKit authorization
        await mindStateManager.fetchLatestMindState()
        
        let computedSummary = MindStateAnalysisEngine.summarize(mindStateManager.allEntries) // .allEntries??? should be last 3 entries
        self.wisdomMessage = WordsOfWisdomEngine.wisdom(for: computedSummary.latestEntry)
        
        withAnimation(.easeInOut(duration: 1.0)) {
            self.summary = computedSummary
            self.wisdomMessage = WordsOfWisdomEngine.wisdom(for: computedSummary.latestEntry)
        }
#else
        // Real device
        do {
            try await mindStateManager.requestAuthorization()
            await mindStateManager.fetchLatestMindState()
            
            let computedSummary = MindStateAnalysisEngine.summarize(mindStateManager.allEntries) // .allEntries??? should be last 3 entries
            self.wisdomMessage = WordsOfWisdomEngine.wisdom(for: computedSummary.latestEntry)
            
            withAnimation(.easeInOut(duration: 0.6)) {
                self.summary = computedSummary
                self.wisdomMessage = WordsOfWisdomEngine.wisdom(for: computedSummary.latestEntry)
            }
            
        } catch {
            self.summary = nil
            self.wisdomMessage = "Unable to fetch mind state."
            print("HealthKit error:", error)
            
            withAnimation(.easeInOut(duration: 0.6)) {
                self.summary = computedSummary
                self.wisdomMessage = WordsOfWisdomEngine.wisdom(for: computedSummary.latestEntry)
            }
        }
#endif
    }
}

#Preview {
    HomeView()
}

