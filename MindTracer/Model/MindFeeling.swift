//
//  MindFeeling.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI

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

extension MindFeeling {
    var baseColor: Color {
        switch self {
        case .happy:     return .yellow
        case .sad:       return .blue.opacity(0.8)   // darker blue
        case .anxious:   return .blue
        case .calm:      return .mint
        case .content:   return .green.opacity(0.6)
        case .excited:   return .orange
        case .stressed:  return .purple
        case .lonely:    return .black
        case .angry:     return .red
        case .tired:     return .gray
        }
    }
}
