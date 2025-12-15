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
    @State private var kind: MindStateKind = MindStateKind.momentaryEmotion
    @State private var valence: Double = 0.0
    @State private var labels: Set<MindFeeling> = []
    @State private var associations: Set<MindContext> = []
    @Binding var showEntrySheet: Bool

    var body: some View {
        NavigationStack {
            EntryStepDateTime(timestamp: $timestamp, coordinate: $coordinate, kind: $kind, valence: $valence, labels: $labels, associations: $associations, showEntrySheet: $showEntrySheet)
            .navigationTitle("New Mind State")
        }
        
    }
}

