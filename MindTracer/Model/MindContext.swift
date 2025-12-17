//
//  MindContext.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//


enum MindContext: String, Codable, CaseIterable, Identifiable {
    case work
    case family
    case friends
    case health
    case meals
    case tasks
    case identity
    case finances
    case relationships
    case travel

    var id: String { rawValue }
}
