//
//  MindFeeling.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//


enum MindFeeling: String, Codable, CaseIterable, Identifiable {
    case happy
    case sad
    case anxious
    case calm
    case content
    case excited
    case stressed
    case lonely
    case angry
    case tired

    var id: String { rawValue }
}
