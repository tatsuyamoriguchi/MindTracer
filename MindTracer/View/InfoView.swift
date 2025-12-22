//
//  InfoView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/21/25.
//

import SwiftUI

struct InfoView: View {
    @StateObject private var store = MindTracerMessageStore()

    var body: some View {
        List(store.messages) { message in
            InfoMessageRow(message: message)
        }
        .onAppear {
            store.fetchMessages()
        }
        .navigationTitle("Mind Tracer Info")
    }
}


#Preview {
    InfoView()
}
