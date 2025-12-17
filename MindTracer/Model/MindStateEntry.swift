//
//  MindStateEntry.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//


import Foundation
import CoreLocation

struct MindStateEntry: Identifiable, Codable, Hashable {
    
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
    let locationName: String?

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
        locationName: String?,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.kind = kind
        self.valence = min(max(valence, -1.0), 1.0)
        self.feelings = feelings
        self.contexts = contexts
        self.location = location.map {CodableCoordinate($0)}
        self.locationName = locationName
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

extension MindStateEntry {
    
    var coordinate: CLLocationCoordinate2D? {
        guard let location else { return nil }
        return CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
    }
    /* Map code
     if let coord = entry.coordinate {
         Annotation("", coordinate: coord) { ... }
     }

     */
}

struct MindStateLocation: Identifiable, Codable {
    let id: String               // "lat,long" or rounded key
    var coordinate: CodableCoordinate
    var entries: [MindStateEntry]
    
    init(id: String, coordinate: CLLocationCoordinate2D, entries: [MindStateEntry]) {
        self.id = id
        self.coordinate = CodableCoordinate(coordinate)
        self.entries = entries
    }
}
