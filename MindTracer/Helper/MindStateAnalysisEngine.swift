//
//  MindStateAnalysisEngine.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import Foundation
import SwiftUI

struct MindStateAnalysisEngine {

    static func summarize(_ entries: [MindStateEntry]) -> MindStateSummary {

        guard !entries.isEmpty else {
            return MindStateSummary(
                latestEntry: nil,
                trend: .unknown,
                dominantFeeling: nil,
                summaryText: "No mind state data yet."
            )
        }

        let sorted = entries.sorted { $0.timestamp < $1.timestamp }
        let latest = sorted.last

        let trend = calculateTrend(from: sorted)
        let dominantFeeling = calculateDominantFeeling(from: sorted)

        let summaryText = buildSummaryText(
            latest: latest,
            trend: trend,
            dominantFeeling: dominantFeeling
        )

        return MindStateSummary(
            latestEntry: latest,
            trend: trend,
            dominantFeeling: dominantFeeling,
            summaryText: summaryText
        )
    }
}

private extension MindStateAnalysisEngine {

    static func calculateTrend(from entries: [MindStateEntry]) -> MoodTrend {

        // If count is less than 2 (0 or 1), return .unknown (opacity 0.40)
        guard entries.count >= 2 else {
            return .unknown
        }

        let recent = entries.suffix(3)
        let values = recent.map { $0.valence }

        // diff between the minimum and maximum valence
        let delta = values.last! - values.first!

        // Determin recent improvement
        if delta > 0.15 {
            return .improving
        } else if delta < -0.15 {
            return .declining
        } else {
            return .stable
        }
    }
}


extension MindStateAnalysisEngine {
    
    // Returns a summary color based on the trend of the most recent three entries
    static func colorForRecentTrend(from entries: [MindStateEntry]) -> Color {
        // 1. Handle empty case
        guard !entries.isEmpty else { return Color.gray.opacity(0.5) }
        
        // 2. Extract recent entries and calculate core values
        let recent = Array(entries.suffix(3))
        let trend = calculateTrend(from: recent)
        let dominantFeeling = calculateDominantFeeling(from: recent)
        
        // 3. Leverage existing properties in MindFeeling and MoodTrend
        // Note: Using a slightly higher opacity multiplier (e.g., * 2.5) if the
        // MoodTrend.opacity values (0.12 - 0.35) feel too faint for the HomeView circle.
        let base = dominantFeeling?.baseColor ?? .gray
        let alpha = trend == .unknown ? 0.5 : trend.opacity * 2.5
        
        return base.opacity(alpha)
    }
}

extension MindStateAnalysisEngine {
    
//    static func calculateDominantFeeling(from entries: [MindStateEntry]) -> MindFeeling? {
//        let recent = entries.suffix(3)
//        let allFeelings = recent.flatMap { $0.feelings }
//        
//        let counts = Dictionary(grouping: allFeelings, by: { $0 })
//            .mapValues { $0.count }
//        
//        // Sort by count, then use the last entry's feeling as a tie-breaker
//        return counts.max { a, b in
//            if a.value == b.value {
//                // If counts are equal, this logic can be expanded,
//                // but usually the first found max is returned.
//                return false
//            }
//            return a.value < b.value
//        }?.key
//    }
    static func calculateDominantFeeling(from entries: [MindStateEntry]) -> MindFeeling? {
        let recent = entries.suffix(3)
        let allFeelings = recent.flatMap { $0.feelings }

        let counts = Dictionary(grouping: allFeelings, by: { $0 })
            .mapValues { $0.count }

        // Sort by count, then by most recent appearance
        return counts
            .sorted { a, b in
                if a.value != b.value {
                    return a.value > b.value
                }

                // tie-breaker: most recent entry wins
                let lastA = recent.last { $0.feelings.contains(a.key) }?.timestamp ?? .distantPast
                let lastB = recent.last { $0.feelings.contains(b.key) }?.timestamp ?? .distantPast
                return lastA > lastB
            }
            .first?
            .key
    }

}


private extension MindStateAnalysisEngine {
    
    static func buildSummaryText(
        latest: MindStateEntry?,
        trend: MoodTrend,
        dominantFeeling: MindFeeling?
    ) -> String {
        
        guard let latest else {
            return "No recent mind state available."
        }
        
        let valenceText = latest.valenceClassification.rawValue
            .replacingOccurrences(of: "very", with: "Very ")
            .capitalized
        
        var parts: [String] = []
        
        parts.append("Your recent mood feels \(valenceText.lowercased()).")
        
        if let feeling = dominantFeeling {
            parts.append("You’ve often felt \(feeling.rawValue).")
        }
        
        switch trend {
        case .improving:
            parts.append("Things seem to be improving.")
        case .declining:
            parts.append("It looks like things have been a bit harder lately.")
        case .stable:
            parts.append("Your mood has been fairly steady.")
        case .unknown:
            break
        }
        
        return parts.joined(separator: " ")
    }
    
}



