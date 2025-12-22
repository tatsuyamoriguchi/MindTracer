//
//  WordsOfWisdomEngine.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import Foundation

import Foundation

struct WordsOfWisdomEngine {

    static func wisdom(for entry: MindStateEntry?) -> String {
        guard let entry else {
            return "Take a deep breath — every day is a new start."
        }

        if entry.feelings.contains(.stressed) {
            return "Stress is temporary. Focus on what you can control right now."
        }

        switch entry.valenceClassification {
        case .veryUnpleasant:
            return "It’s okay to pause and reset. Small steps matter."
        case .unpleasant:
            return "Remember to take a break and focus on something positive."
        case .neutral:
            return "Steady progress is still progress — keep going!"
        case .pleasant:
            return "Good feelings! Keep nurturing what makes you happy."
        case .veryPleasant:
            return "Your mood is shining — share the positivity around you!"
        }
    }

}
