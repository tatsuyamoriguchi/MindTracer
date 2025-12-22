//
//  MindTracerMessageStore.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/21/25.
//

import Foundation
import CloudKit

final class MindTracerMessageStore: ObservableObject {
    @Published var messages: [MindTracerMessage] = []

    private let database = CKContainer.default().publicCloudDatabase

    func fetchMessages() {
//        let predicate = NSPredicate(value: true)
//        let predicate = NSPredicate(format: "isActive == 1")
        let predicate = NSPredicate(format: "isActive == %d", 1)

        let query = CKQuery(recordType: "MindTracerMessage", predicate: predicate)
        query.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        database.fetch(withQuery: query) { result in
            switch result {
            case .success(let result):
                let mapped = result.matchResults.compactMap { _, recordResult -> MindTracerMessage? in
                    guard let record = try? recordResult.get(),
                          let title = record["title"] as? String,
                          let body = record["body"] as? String,
                          let category = record["category"] as? String,
                          let isActive = record["isActive"] as? Int64
                    else { return nil }

                    guard let record = try? recordResult.get() else {
                        print("Failed to get record")
                        return nil
                    }

                    return MindTracerMessage(
                        id: record.recordID,
                        date: record.creationDate ?? Date(),
                        title: title,
                        body: body,
                        category: MessageCategory(rawValue: category) ?? .unknown,
                        isActive: isActive
                    )
                }

                DispatchQueue.main.async {
                    self.messages = mapped
                }

            case .failure(let error):
                print("CloudKit fetch error:", error)
            }
        }
    }
}
