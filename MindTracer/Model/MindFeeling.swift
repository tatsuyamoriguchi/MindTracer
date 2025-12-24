//
//  MindFeeling.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI

enum MindFeeling: String, Codable, CaseIterable, Identifiable {
    case happy
    case excited
    case content
    case calm
    case tired
    case stressed
    case angry
    case anxious
    case lonely
    case sad
    case neutral

    var id: String { rawValue }
}

// cyan indigo mint pink teal

extension MindFeeling {
    var baseColor: Color {
        switch self {
        case .happy:     return .yellow
        case .excited:   return .orange
        case .content:   return .teal
        case .calm:      return .mint
        case .tired:     return .brown
        case .stressed:  return .indigo
        case .angry:     return .red
        case .sad:       return .blue
        case .anxious:   return .pink
        case .lonely:    return .black
        case .neutral:  return .gray
        }
    }
}
