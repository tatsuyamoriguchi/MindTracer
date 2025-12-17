//
//  CodableCoordinate.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//


import Foundation
import CoreLocation

struct CodableCoordinate: Codable, Equatable, Hashable {
    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var clLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension CodableCoordinate {
    var roundedKey: String {
        "\(round(latitude * 1000) / 1000),\(round(longitude * 1000) / 1000)"
    }
}

