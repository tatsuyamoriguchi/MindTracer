//
//  MindTracerMessage.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/21/25.
//

import Foundation
import CloudKit

struct MindTracerMessage: Identifiable {
    let id: CKRecord.ID
    let date: Date
    let title: String
    let body: String
    let category: MessageCategory
    let isActive: Int64
}

enum MessageCategory: String, Codable, CaseIterable, Identifiable  {
    case support = "Support"
    case administration = "Administration"
    case marketing = "Marketing"
    case unknown = "Unknown"
    
    var id: String { rawValue }
}


