//
//  MindStateDetailView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/17/25.
//

import SwiftUI

struct MindStateDetailView: View {

    let entry: MindStateEntry

    var body: some View {
        
        List {
            Text("Kind: \(entry.kind)")
            Text("Valence: \(entry.valence)")
            Text("Classification: \(entry.valenceClassification.rawValue)")
            Text("Timestamp: \(entry.timestamp.formatted())")

            if let name = entry.locationName {
                Text("Location: \(name)")
            }

            if !entry.feelings.isEmpty {
                Text("Feelings: \(entry.feelings.map(\.rawValue).joined(separator: ", "))")
            }

            if !entry.contexts.isEmpty {
                Text("Contexts: \(entry.contexts.map(\.rawValue).joined(separator: ", "))")
            }
        }
        .navigationTitle("Mind State Detail View")
          .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    MindStateDetailView(
        entry: MindStateEntry(
            timestamp: Date(timeIntervalSince1970: 1_700_000_000), kind: .momentaryEmotion,
            valence: 0.45,
            feelings: [.calm, .tired],
            contexts: [.work],
            location: nil,
            locationName: "Home",
            metadata: [
                "source": "preview"
            ]
        )
    )
}


