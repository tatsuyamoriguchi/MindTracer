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
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    
    @State private var selectedLocationID: String?
    private var selectedLocation: MindStateLocation? {
        guard let id = selectedLocationID else { return nil }
        return store.locations.first(where: { $0.id == id })
    }



    
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
        .task {
            // Attempt to get the current location asynchronously
            if let location = await LocationManager.shared.getCurrentLocation() {
                let miles: Double = 1
                let meters = miles * 1609.34
                let span = MKCoordinateSpan(
                    latitudeDelta: meters / 111_000,
                    longitudeDelta: meters / (111_000 * cos(location.coordinate.latitude * .pi / 180))
                )
                
                cameraPosition = .region(
                    MKCoordinateRegion(center: location.coordinate, span: span)
                )
            }
        }
    }
    @MapContentBuilder
    private func mapPin(for location: MindStateLocation) -> some MapContent {
        Annotation("", coordinate: location.coordinate.clLocationCoordinate2D) {
            VStack(spacing: 2) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(
                        location.id == selectedLocation?.id ? .red : .blue
                    )
                Text(location.entries.last?.locationName ?? "")
                    .font(.caption)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }
            .onTapGesture {
                selectedLocationID = location.id
            }

        }
    }
    

    @ViewBuilder
    private var listSection: some View {
        if let location = selectedLocation {
            List {
                ForEach(location.entries) { entry in
                    NavigationLink(value: entry) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(entry.kind.description)
                                    .font(.body)
                                Text(entry.valenceClassification.rawValue.description)
                            }
                            HStack {
                                Text(entry.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(entry.timestamp, style: .time)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    deleteEntries(at: indexSet, from: location)
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
    
    private func deleteEntries(at offsets: IndexSet, from location: MindStateLocation) {
        store.deleteEntries(at: offsets, for: location)
    }


    
}

#Preview {
    MapView()
}
