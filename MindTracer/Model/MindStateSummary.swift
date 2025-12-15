//
//  MindStateSummary.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import Foundation

struct MindStateSummary {
    let latestEntry: MindStateEntry?
    let trend: MoodTrend
    let dominantFeeling: MindFeeling?
    let summaryText: String
}
enum MoodTrend: String {
    case improving
    case stable
    case declining
    case unknown
}

