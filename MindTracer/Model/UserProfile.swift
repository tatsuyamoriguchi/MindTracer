//
//  UserProfile.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 11/11/25.
//

import Foundation
import CloudKit

/*
 Later (recommended for v2 polish), we’ll split this into:
 UserProfile          ← pure model
 UserProfileStore     ← CloudKit logic
 But do not refactor yet — you’re doing the right thing by stabilizing first.
 */

final class UserProfile: ObservableObject, Identifiable {
    private let privateDB = CKContainer.default().privateCloudDatabase
    var recordID: CKRecord.ID
    @Published var displayName: String?
    @Published var email: String?
    @Published var createdAt: Date
    @Published var lastLogin: Date?

    init(record: CKRecord) {
        self.recordID = record.recordID
        self.displayName = record["displayName"] as? String
        self.email = record["email"] as? String
        self.createdAt = record["createdAt"] as? Date ?? Date()
        self.lastLogin = record["lastLogin"] as? Date
    }

    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "UserProfile", recordID: self.recordID)

        if let displayName {
            record["displayName"] = displayName as CKRecordValue
        }

        if let email {
            record["email"] = email as CKRecordValue
        }

        record["createdAt"] = createdAt as CKRecordValue
        record["lastLogin"] = lastLogin as? CKRecordValue

        return record
    }
    
    func loadOrCreateUserProfile() async throws -> UserProfile {
        // 1. Try to fetch existing record
        let recordID = CKRecord.ID(recordName: CKCurrentUserDefaultName)
        do {
            let record = try await privateDB.record(for: recordID)
            return UserProfile(record: record)
        } catch {
            // 2. If record doesn’t exist → create using CKCurrentUserDefaultName
            let newRecord = CKRecord(recordType: "UserProfile", recordID: recordID)
            newRecord["createdAt"] = Date() as CKRecordValue
            newRecord["lastLogin"] = Date() as CKRecordValue

            let savedRecord = try await privateDB.save(newRecord)
            return UserProfile(record: savedRecord)
        }
    }


}

