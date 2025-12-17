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
    @State private var savedLocations: [MindStateLocation] = []
    @State private var locationName: String? = ""
    @State private var selectedLocation: MindStateLocation?
    
    
    var body: some View {
        VStack(spacing: 16) {
            mapView
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            locationNameTextField
            
            useLocationButton
            
            savedLocationsList
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
                showEntrySheet: $showEntrySheet,
                locationName: $locationName
            )
        }
        .task {
            savedLocations = loadSavedLocations()
            if coordinate == nil, let loc = await LocationManager.shared.getCurrentLocation() {
                coordinate = loc.coordinate
                cameraPosition = .region(
                    MKCoordinateRegion(
                        center: loc.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
            }
        }
        
    }
    
    private var mapView: some View {
        MapReader { proxy in
            Map(position: $cameraPosition, interactionModes: .all) {
                mapAnnotations()
            }
            .onTapGesture { point in
                if let mapCoordinate = proxy.convert(point, from: .local) {
                    coordinate = mapCoordinate
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: mapCoordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
    }
    
//    @MapContentBuilder
//    private func mapAnnotations() -> some MapContent {
//        
//        // Selected coordinate (user just tapped or current location)
//        if let coordinate {
//            Annotation("Selected Location", coordinate: coordinate) {
//                VStack(spacing: 4) {
//                    if let name = locationName, !name.isEmpty {
//                        Text(name)
//                            .font(.caption)
//                            .bold()
//                            .padding(4)
//                            .background(Color.white.opacity(0.8))
//                            .cornerRadius(6)
//                            .shadow(radius: 2)
//                    }
//                    Image(systemName: "mappin.circle.fill")
//                        .font(.title)
//                        .foregroundStyle(.red)
//                }
//            }
//        }
//        
//        // Saved locations
//        ForEach(savedLocations) { location in
//            Annotation(location.entries.last?.locationName ?? "Unknown", coordinate: location.coordinate.clLocationCoordinate2D) {
//                VStack(spacing: 4) {
//                    Text(location.entries.last?.locationName ?? "Unknown")
//                        .font(.caption)
//                        .bold()
//                        .padding(4)
//                        .background(Color.white.opacity(0.8))
//                        .cornerRadius(6)
//                        .shadow(radius: 2)
//                    
//                    Image(systemName: "mappin.circle.fill")
//                        .font(.title)
//                        .foregroundStyle(location.id == selectedLocation?.id ? .red : .blue)
//                        .onTapGesture {
//                            selectedLocation = location
//                            coordinate = location.coordinate.clLocationCoordinate2D
//                            locationName = location.entries.last?.locationName
//                        }
//                }
//            }
//        }
//    }
    
    @MapContentBuilder
    private func mapAnnotations() -> some MapContent {

        ForEach(savedLocations) { location in
            Annotation(
                "",
                coordinate: location.coordinate.clLocationCoordinate2D
            ) {
                VStack(spacing: 4) {

                    // Label
                    Text(
                        selectedLocation?.id == location.id
                        ? "Selected Location"
                        : (location.entries.last?.locationName ?? "")
                    )
                    .font(.caption)
                    .bold()
                    .padding(4)
                    .background(Color.white.opacity(0.85))
                    .cornerRadius(6)
                    .shadow(radius: 2)

                    // Pin
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundStyle(
                            selectedLocation?.id == location.id ? .red : .blue
                        )
                }
                .onTapGesture {
                    selectLocation(location)
                }
            }
        }
    }

    
    private var locationNameTextField: some View {
            TextField("Enter Location Name", text: Binding(
                get: { locationName ?? "" },
                set: { locationName = $0 }
            ))
            .textFieldStyle(.roundedBorder)
            .padding(.horizontal)
        }
        
    private var useLocationButton: some View {
        Button("Use This Location") {
            saveEntry()
            isEntryStepMindStatePresented = true
        }
        .buttonStyle(.borderedProminent)
        .disabled(coordinate == nil)
    }
        
    @ViewBuilder
    private var savedLocationsList: some View {
        if !savedLocations.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Saved Locations")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(savedLocations) { location in
                            Button(action: {
                                selectLocation(location)
                            }) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(location.id == selectedLocation?.id ? .red : .blue)
                                    Text(location.entries.last?.locationName ?? "Unknown")
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.gray.opacity(location.id == selectedLocation?.id ? 0.2 : 0.05))
                                )
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            .padding(.vertical)
        }
    }

    
    
//    private func selectLocation(_ location: MindStateLocation) {
//        coordinate = location.coordinate.clLocationCoordinate2D
//        locationName = location.entries.last?.locationName ?? "Selected Place"
//        cameraPosition = .region(
//            MKCoordinateRegion(
//                center: location.coordinate.clLocationCoordinate2D,
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            )
//        )
//        selectedLocation = location
//    }
    private func selectLocation(_ location: MindStateLocation) {
        selectedLocation = location
        coordinate = location.coordinate.clLocationCoordinate2D
        locationName = location.entries.last?.locationName

        cameraPosition = .region(
            MKCoordinateRegion(
                center: location.coordinate.clLocationCoordinate2D,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    
    private func saveEntry() {
        guard let coordinate else { return }
        let entry = MindStateEntry(
            timestamp: timestamp,
            kind: kind,
            valence: valence,
            feelings: Array(labels),
            contexts: Array(associations),
            location: coordinate,
            locationName: locationName
        )
        
        if let index = savedLocations.firstIndex(where: { $0.id == "\(coordinate.latitude),\(coordinate.longitude)" }) {
            var loc = savedLocations[index]
            loc.entries.append(entry)
            savedLocations[index] = loc
        } else {
            let newLocation = MindStateLocation(
                id: "\(coordinate.latitude),\(coordinate.longitude)",
                coordinate: coordinate,
                entries: [entry]
            )
            savedLocations.insert(newLocation, at: 0)
        }
        
        saveLocations()
    }
    
    // MARK: - JSON Persistence
    
    private func loadSavedLocations() -> [MindStateLocation] {
        let url = getSavedLocationsURL()
        guard let data = try? Data(contentsOf: url),
              let locations = try? JSONDecoder().decode([MindStateLocation].self, from: data) else {
            return []
        }
        return locations
    }
    
    private func saveLocations() {
        let url = getSavedLocationsURL()
        if let data = try? JSONEncoder().encode(savedLocations) {
            try? data.write(to: url)
        }
    }
    
    private func getSavedLocationsURL() -> URL {
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docDir.appendingPathComponent("SavedLocations.json")
    }
    
}
