//
//  EntryStepDateTime.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//

import SwiftUI

struct EntryStepDateTime: View {
    @Binding var timestamp: Date
    
    var body: some View {
        Form {
            DatePicker("Timestamp", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
        }
        .navigationTitle("Date & Time")
    }
}

