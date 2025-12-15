//
//  EntryStepLocation.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct EntryStepLocation: View {

    @Binding var timestamp: Date
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var kind: MindStateKind
    @Binding var valence: Double
    @Binding var labels: Set<MindFeeling>
    @Binding var associations: Set<MindContext>
    @Binding var showEntrySheet: Bool
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isEntryStepMindStatePresented: Bool = false

    var body: some View {
        VStack(spacing: 16) {

            Map(position: $cameraPosition) {
                if let coordinate {
                    Annotation("Selected Location", coordinate: coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button("Use Current Location") {
                Task {
                    if let loc = await LocationManager.shared.getCurrentLocation() {
                        coordinate = loc.coordinate
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: loc.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        )
                    } else {
                        // Simulator-safe fallback
                        let dummy = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
                        coordinate = dummy
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: dummy,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        )
                    }
                    isEntryStepMindStatePresented = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $isEntryStepMindStatePresented) {
            EntryStepMindState(
                kind: $kind,
                valence: $valence,
                labels: $labels,
                associations: $associations,
                timestamp: $timestamp,
                coordinate: $coordinate,
                showEntrySheet: $showEntrySheet
            )
        }
    }
}
