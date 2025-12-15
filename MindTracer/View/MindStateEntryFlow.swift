//
//  MindStateEntryFlow.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//

import SwiftUI
import CoreLocation
import MapKit

struct MindStateEntryFlow: View {
    @State private var timestamp = Date()
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var kind: String = "momentaryEmotion"
    @State private var valence: Double = 0.0
    @State private var valenceClassification: String = "Neutral"
    @State private var labels: Set<MindFeeling> = []
    @State private var associations: Set<MindContext> = []

    @State private var showLocationStep = false
    @State private var showMindStateStep = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                DatePicker("Timestamp", selection: $timestamp)
                    .datePickerStyle(.compact)
                
                Button("Next: Location") {
                    showLocationStep = true
                }
                .navigationDestination(isPresented: $showLocationStep) {
                    EntryStepLocation(coordinate: $coordinate)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Next") {
                                    showMindStateStep = true
                                }
                            }
                        }
                }

                NavigationLink(destination: MindStateStep(
                    kind: $kind,
                    valence: $valence,
                    valenceClassification: $valenceClassification,
                    labels: $labels,
                    associations: $associations,
                    timestamp: timestamp,
                    coordinate: coordinate
                ), isActive: $showMindStateStep) {
                    EmptyView()
                }
            }
            .padding()
            .navigationTitle("New Mind State")
        }
    }
}

