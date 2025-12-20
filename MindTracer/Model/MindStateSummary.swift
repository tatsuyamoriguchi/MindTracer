//
//  MindStateSummary.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import Foundation
import SwiftUI

struct MindStateSummary {
    let latestEntry: MindStateEntry?
    let trend: MoodTrend
    let dominantFeeling: MindFeeling?
    let summaryText: String
}

extension MindStateSummary {
    var backgroundColor: Color {
        guard let feeling = dominantFeeling else {
            return Color.gray.opacity(0.15)
        }

        let base = feeling.baseColor
        let opacity = trend.opacity

        return base.opacity(opacity)
    }
}


enum MoodTrend: String {
    case improving
    case stable
    case declining
    case unknown
}

extension MoodTrend {
    var opacity: Double {
        switch self {
        case .improving:
            return 0.35   // high presence, still subtle
        case .stable:
            return 0.22
        case .declining:
            return 0.12
        case .unknown:
            return 0.18
        }
    }

    var fallbackColor: Color {
        switch self {
        case .unknown:
            return .gray
        default:
            return .clear
        }
    }
}


