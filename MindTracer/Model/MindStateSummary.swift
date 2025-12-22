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
