//
//  MindStateAnalysisEngine.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import Foundation

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

        guard entries.count >= 2 else {
            return .stable
        }

        let recent = entries.suffix(3)
        let values = recent.map { $0.valence }

        let delta = values.last! - values.first!

        if delta > 0.15 {
            return .improving
        } else if delta < -0.15 {
            return .declining
        } else {
            return .stable
        }
    }
}

private extension MindStateAnalysisEngine {

    static func calculateDominantFeeling(from entries: [MindStateEntry]) -> MindFeeling? {

        let allFeelings = entries.flatMap { $0.feelings }

        let counts = Dictionary(grouping: allFeelings, by: { $0 })
            .mapValues { $0.count }

        return counts.max(by: { $0.value < $1.value })?.key
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


