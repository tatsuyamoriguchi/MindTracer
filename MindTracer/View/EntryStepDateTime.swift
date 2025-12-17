//
//  EntryStepDateTime.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//

import SwiftUI
import CoreLocation

struct EntryStepDateTime: View {
    @Binding var timestamp: Date
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var kind: MindStateKind
    @Binding var valence: Double
    @Binding var labels: Set<MindFeeling>
    @Binding var associations: Set<MindContext>
    @Binding var showEntrySheet: Bool
    
    @State var isEntryStepLocationPresented: Bool = false
    
    var body: some View {
        Form {
            DatePicker("Timestamp", selection: $timestamp, displayedComponents: [.date, .hourAndMinute])
            Button {
                isEntryStepLocationPresented = true
            } label: {
                Text("Next")
            }
        }
        .navigationTitle("Date & Time")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isEntryStepLocationPresented) {
            EntryStepLocation(
                timestamp: $timestamp,
                coordinate: $coordinate,
                kind: $kind,
                valence: $valence,
                labels: $labels,
                associations: $associations,
                showEntrySheet: $showEntrySheet
            )
        }
    }
}
