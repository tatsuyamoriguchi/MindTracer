//
//  HealthKitReference.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/16/25.
//

import Foundation

struct HealthKitReference: Codable {
    let uuid: UUID          // HKSample.uuid
    let startDate: Date
}
