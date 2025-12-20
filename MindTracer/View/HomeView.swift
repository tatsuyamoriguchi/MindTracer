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
    
    @State private var pulse: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                content
                
                if let summary {
                    ZStack {
                        // Flaring layer
                        Circle()
                            .fill(summary.backgroundColor)
                            .frame(width: 230, height: 230)
                            .scaleEffect(pulse ? 1.2 : 1.0) // grows and shrinks
                            .opacity(pulse ? 0.2 : 0.8)     // fade in/out
                            .blur(radius: 10)
                        
                        // Main circle
                        Circle()
                            .fill(summary.backgroundColor)
                            .frame(width: 200, height: 200)
                            .shadow(radius: 5)
                            .padding()
                            .animation(.easeInOut(duration: 0.6), value: summary.backgroundColor)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                            pulse.toggle()
                        }
                    }
                // Latest analysis summary
//                if let summary {
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
           
        }
        .preferredColorScheme(.dark)
        
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
        
        let computedSummary = MindStateAnalysisEngine.summarize(mindStateManager.allEntries)
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
            
            let computedSummary = MindStateAnalysisEngine.summarize(mindStateManager.allEntries)
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

