//
//  InfoMessageRow.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/21/25.
//

import SwiftUI
import CloudKit

struct InfoMessageRow: View {
    let message: MindTracerMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message.category.rawValue)
                .font(.caption2)
            Text(message.title)
                .font(.headline)

            Text(message.body)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text(message.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    sendEmail(message: message)
                } label: {
                    Image(systemName: "envelope")
                }
            }
        }
        .padding(.vertical, 6)
    }
    
    func sendEmail(message: MindTracerMessage) {
        let subject = "Mind Tracer Inquiry: \(message.title)"
        let body =
    """
    Regarding the following Mind Tracer message:

    Title: \(message.title)
    Date: \(message.date)

    Message:
    \(message.body)

    ---------------------
    My question:
    """

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        let urlString = "mailto:support@mindtracer.app?subject=\(encodedSubject)&body=\(encodedBody)"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}


#Preview {
    InfoMessageRow(
        message: MindTracerMessage(
            id: CKRecord.ID(recordName: "preview-message"),
            date: Date(),
            title: "New Features Coming Soon",
            body: """
            We’re working on new insights and visualizations to help you better understand your mind trends.

            Stay tuned for updates and thank you for using Mind Tracer!
            """,
            category: .administration,
            isActive: 1
        )
    )
    .padding()
}
