//
//  EntryStepLocation.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct EntryStepLocation: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        VStack {
            // Only one optional pin
            let pins = coordinate.map { [MapPin(coordinate: $0)] } ?? []
            
            Map(
                coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: pins
            ) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.title)
                }
            }
            .frame(height: 300)
            
            Button("Use Current Location") {
                Task {
                    if let loc = await LocationManager.shared.getCurrentLocation() {
                        coordinate = loc.coordinate
                        region.center = loc.coordinate
                    } else {
                        // Simulator fallback
                        let dummy = CLLocationCoordinate2D(latitude: 37.3349, longitude: -122.0090)
                        coordinate = dummy
                        region.center = dummy
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Location")
    }
}
