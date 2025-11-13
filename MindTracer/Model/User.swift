//
//  User.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 11/11/25.
//

import Foundation
import CloudKit

final class User: ObservableObject, Identifiable {
    var recordID: CKRecord.ID
    @Published var userID: String
    @Published var displayName: String?
    @Published var createdAt: Date
    @Published var lastLogin: Date?

    init(record: CKRecord) {
        self.recordID = record.recordID
        self.userID = record["userID"] as? String ?? ""
        self.displayName = record["displayName"] as? String
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.lastLogin = record["lastLogin"] as? Date
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "User", recordID: recordID)
        record["userID"] = userID as CKRecordValue
        record["displayName"] = displayName as CKRecordValue?
        record["createdAt"] = createdAt as CKRecordValue
        record["lastLogin"] = lastLogin as CKRecordValue?
        return record
    }
}

