//
//  SubscriptionStatus.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 11/11/25.
//

import Foundation
import CloudKit

final class SubscriptionStatus: ObservableObject, Identifiable {
    var recordID: CKRecord.ID
    var userReference: CKRecord.Reference?
    @Published var tier: AccessLevel
    @Published var expiresOn: Date?
    @Published var lastVerified: Date?

    init(record: CKRecord) {
        self.recordID = record.recordID
        self.userReference = record["userReference"] as? CKRecord.Reference
        if let tierString = record["tier"] as? String,
           let level = AccessLevel(rawValue: tierString) {
            self.tier = level
        } else {
            self.tier = .free
        }
        self.expiresOn = record["expiresOn"] as? Date
        self.lastVerified = record["lastVerified"] as? Date
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "PurchaseStatus", recordID: recordID)
        record["userReference"] = userReference
        record["tier"] = tier.rawValue as CKRecordValue
        record["expiresOn"] = expiresOn as CKRecordValue?
        record["lastVerified"] = lastVerified as CKRecordValue?
        return record
    }
}
