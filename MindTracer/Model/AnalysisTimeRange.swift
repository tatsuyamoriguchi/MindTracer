//
//  AnalysisTimeRange.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/17/25.
//

import Foundation

enum AnalysisTimeRange: String, CaseIterable, Identifiable {
    case past8Hours
    case past3Days
    case past7Days
    case past30Days
    case past90Days
    case pastYear
    case all

    var id: String { rawValue }
    
    var displayName: String {
            switch self {
            case .past8Hours: return "8 Hrs"
            case .past3Days: return "3 Days"
            case .past7Days: return "7 Days"
            case .past30Days: return "30 Days"
            case .past90Days: return "90 Days"
            case .pastYear: return "Year"
            case .all: return "All Time"
            }
        }
}
