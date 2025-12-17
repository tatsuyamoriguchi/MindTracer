//
//  MindStateLocation.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/17/25.
//

import Foundation
import CoreLocation

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
