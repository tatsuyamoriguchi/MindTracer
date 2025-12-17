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

    
    var body: some View {
        VStack(spacing: 16) {
            
            MapReader { proxy in
                Map(position: $cameraPosition, interactionModes: .all) {
//                    if let coordinate {
//                        Annotation("Selected Location", coordinate: coordinate) {
//                            Image(systemName: "mappin.circle.fill")
//                                .font(.title)
//                                .foregroundStyle(.red)
//                        }
//                    }
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
                        // Optional: clear previous locationName to let user enter a new one
                        locationName = ""
                    }
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // TextField to enter or edit location name
            TextField("Enter Location Name", text: $locationName?)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
//            TextField("Enter Location Name", text: Binding(
//                get: { locationName ?? "" },
//                set: { locationName = $0 }
//            ))
//            .textFieldStyle(.roundedBorder)
//            .padding(.horizontal)
            
            
            Button("Use This Location") {
                saveEntry()
                isEntryStepMindStatePresented = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(coordinate == nil)
            
            if !savedLocations.isEmpty {
                Menu("Recent Locations") {
                    ForEach(savedLocations) { location in
//                        Button(location.id) { // or use a friendly display name if available
//                            selectLocation(location)
//                        }
                        Button(location.entries.last?.locationName ?? location.id) {
                            selectLocation(location)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .onAppear {
            Task {
                // Load previously saved locations from JSON
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
    }
    
    @ViewBuilder
    private func mapAnnotations() -> some MapContent {
        if let coordinate {
            Annotation("Selected Location", coordinate: coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(.red)
            }
        }
        
        ForEach(savedLocations) { location in
            Annotation("", coordinate: location.coordinate.clLocationCoordinate2D) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title)
                    .foregroundStyle(location.id == selectedLocation?.id ? .red : .blue)
                    .onTapGesture { selectedLocation = location }
            }
        }
    }

//    func selectLocation(_ location: MindStateLocation) {
//        coordinate = location.coordinate
//        locationName = location.entries.last?.locationName ?? "Selected Place"
//        cameraPosition = .region(
//            MKCoordinateRegion(
//                center: location.coordinate,
//                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//            )
//        )
//        
//        guard let coordinate else { return }
//        
//        let entry = MindStateEntry(
//            timestamp: timestamp,
//            kind: kind,
//            valence: valence,
//            feelings: Array(labels),
//            contexts: Array(associations),
//            location: coordinate,
//            locationName: locationName
//        )
//        
//        if let index = savedLocations.firstIndex(where: { $0.id == "\(coordinate.latitude),\(coordinate.longitude)" }) {
//            var loc = savedLocations[index]
//            loc.entries.append(entry)
//            savedLocations[index] = loc
//        } else {
//            let newLocation = MindStateLocation(
//                id: "\(coordinate.latitude),\(coordinate.longitude)",
//                coordinate: coordinate,
//                entries: [entry]
//            )
//            savedLocations.insert(newLocation, at: 0)
//        }
//        
//        // Persist savedLocations if needed
//    }
    private func selectLocation(_ location: MindStateLocation) {
            coordinate = location.coordinate
            locationName = location.entries.last?.locationName ?? "Selected Place"
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: location.coordinate,
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
