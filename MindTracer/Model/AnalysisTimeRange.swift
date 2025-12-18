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
}
