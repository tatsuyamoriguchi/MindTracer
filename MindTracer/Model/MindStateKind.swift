//
//  MindStateKind.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//


//enum MindStateKind: String, Codable, CaseIterable {
//    case momentaryEmotion
//    case dailyMood
//}

enum MindStateKind: String, Codable, Hashable, CustomStringConvertible {
    case momentaryEmotion = "Momentary Emotion"
    case dailyMood = "Daily Mood"

    var description: String { rawValue }
}

