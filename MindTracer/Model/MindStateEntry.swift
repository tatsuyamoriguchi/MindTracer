//
//  MindStateEntry.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//


import Foundation
import CoreLocation

struct MindStateEntry: Identifiable, Codable {
    
    let id: UUID

    // Time
    let timestamp: Date

    // Type
    let kind: MindStateKind

    // Core feeling
    let valence: Double        // –1.0 ... +1.0
    let feelings: [MindFeeling]
    let contexts: [MindContext]

    // Optional
    let location: CodableCoordinate?

    // Metadata (machine-use only)
    let metadata: [String: String]?

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        kind: MindStateKind,
        valence: Double,
        feelings: [MindFeeling],
        contexts: [MindContext] = [],
        location: CLLocationCoordinate2D? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.kind = kind
        self.valence = min(max(valence, -1.0), 1.0)
        self.feelings = feelings
        self.contexts = contexts
        self.location = location.map {CodableCoordinate($0)}
        self.metadata = metadata
    }
}

extension MindStateEntry {

    var valenceClassification: ValenceClassification {
        switch valence {
        case ..<(-0.6): return .veryUnpleasant
        case -0.6..<(-0.2): return .unpleasant
        case -0.2...0.2: return .neutral
        case 0.2...0.6: return .pleasant
        default: return .veryPleasant
        }
    }
}

