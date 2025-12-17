//
//  MapView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var store = MindStateStore()
    @State private var selectedLocation: MindStateLocation?
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mapSection
                Divider()
                listSection
            }
            .navigationTitle("Mind Map")
            .navigationDestination(for: MindStateEntry.self) { entry in
                MindStateDetailView(entry: entry)
            }
            .onAppear {
                store.load()
            }
        }
    }
    private var mapSection: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()
            
            ForEach(store.locations, id: \.id) { location in
                mapPin(for: location)
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.45)
    }
    
    @MapContentBuilder
    private func mapPin(for location: MindStateLocation) -> some MapContent {
        Annotation("", coordinate: location.coordinate.clLocationCoordinate2D) {
            
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundStyle(
                    location.id == selectedLocation?.id ? .red : .blue
                )
                .onTapGesture {
                    selectedLocation = location
                }
            
        }
    }
    
    @ViewBuilder
    private var listSection: some View {
        if let location = selectedLocation {
            
            List(location.entries) { entry in
                NavigationLink(value: entry) {
                    VStack(alignment: .leading) {
                        Text(entry.kind.description)
                            .font(.headline)
                        Text(entry.timestamp, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

        } else {
            ContentUnavailableView(
                "Select a location",
                systemImage: "mappin.and.ellipse",
                description: Text("Tap a pin to see past Mind States")
            )
        }
    }
    
}

#Preview {
    MapView()
}
