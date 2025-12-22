//
//  MoodTrend.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/21/25.
//

import Foundation
import SwiftUI

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
            return 0.90   // high presence, still subtle
        case .stable:
            return 0.60
        case .declining:
            return 0.10
        case .unknown:
            return 0.40
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
