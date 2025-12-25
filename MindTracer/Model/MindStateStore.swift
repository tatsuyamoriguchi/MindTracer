//
//  MindStateStore.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/16/25.
//

import Foundation

@MainActor
final class MindStateStore: ObservableObject {

    @Published private(set) var entries: [MindStateEntry] = []
    private let fileURL: URL
    static var instanceCount = 0

    init() {
        let baseURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!

        let appFolder = baseURL.appendingPathComponent("MindTracer", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: appFolder,
            withIntermediateDirectories: true
        )

        self.fileURL = appFolder.appendingPathComponent("mind_states.json")

        load()
        
#if DEBUG
        
        Self.instanceCount += 1
           assert(Self.instanceCount == 1, "❌ Multiple MindStateStore instances detected")
        if entries.isEmpty {
            generateTestEntries()
            save()
        }
#endif
    }
    
    // For Map
    var locations: [MindStateLocation] {
        // 1️⃣ Group entries by rounded coordinate key
        let grouped = Dictionary(grouping: entries) { entry in
            entry.location?.roundedKey ?? "unknown"
        }

        // 2️⃣ Convert grouped dictionary into [MindStateLocation]
        return grouped.compactMap { key, entries in
            guard let location = entries.first?.location else {
                return nil
            }
            
            return MindStateLocation(
                id: key,
                coordinate: location.clLocationCoordinate2D,
                entries: entries.sorted { $0.timestamp > $1.timestamp }
            )
        }
    }
}

extension MindStateStore {

    func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            entries = []
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([MindStateEntry].self, from: data)
        } catch {
            print("Failed to load mind states:", error)
            entries = []
        }
    }
    /* Usage
     ForEach(store.entries) { entry in
         Text(entry.valenceClassification.rawValue)
     }
     */
    
    func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: [.atomic]) // .atomic prevents partial file corruption
        } catch {
            print("Failed to save mind states:", error)
        }
    }
    /* Usage
     let entry = MindStateEntry(...)
     store.add(entry)
     */
    
    /*
     Application Support/
     └── MindTracer/
         └── mind_states.json
     */
}

extension MindStateStore {

    func add(_ entry: MindStateEntry) {
        entries.append(entry)
        save()
    }

    func delete(_ entry: MindStateEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func replace(_ entry: MindStateEntry) {
        guard let index = entries.firstIndex(where: { $0.id == entry.id }) else {
            return
        }
        entries[index] = entry
        save()
    }
}

extension MindStateStore {
    func deleteEntries(at offsets: IndexSet, for location: MindStateLocation) {
        // Find entries in the store that match the entries being shown for this location
        let entryIDsToDelete = offsets.map { location.entries[$0].id }

        // Remove from the underlying entries array
        entries.removeAll { entryIDsToDelete.contains($0.id) }

        save() // persist the change
    }
}

extension MindStateStore {
#if DEBUG
    func generateTestEntries(days: Int = 30) {
        let now = Date()
        let calendar = Calendar.current

        let demoLocations: [(Double, Double, String)] = [
            (37.7749, -122.4194, "San Francisco"),
            (34.0522, -118.2437, "Los Angeles"),
            (40.7128, -74.0060, "New York"),
            (47.6062, -122.3321, "Seattle"),
            (51.5074, -0.1278, "London")
        ]

        entries = (0..<days).flatMap { dayOffset in
            // One base mood per day to avoid flat lines
            let dailyBias = Double.random(in: -0.6...0.6)
            
            return (0..<Int.random(in: 3...8)).map { _ in
                let date = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
                
                // Valence with daily bias and small noise, clamped to [-1,1]
                let rawValence = dailyBias + Double.random(in: -0.3...0.3)
                let valence = min(max(rawValence, -1.0), 1.0)
                
                // Determine feelings from valence
                let feeling: MindFeeling? = valence > 0 ? .happy : valence < 0 ? .sad : nil

                // Randomly pick a demo location or nil
                let useLocation = Bool.random()
                let demoLocation = demoLocations.randomElement()
                
                return MindStateEntry(
                    timestamp: date,
                    kind: Bool.random() ? .momentaryEmotion : .dailyMood,
                    valence: valence,
                    feelings: feeling != nil ? [feeling!] : [],
                    contexts: [],
                    location: useLocation ? .init(
                        latitude: demoLocation!.0,
                        longitude: demoLocation!.1
                    ) : nil,
                    locationName: useLocation ? demoLocation!.2 : nil
                )
            }
        }
    }
#endif
}

//extension MindStateStore {
//#if DEBUG
//    
//    func generateTestEntries(days: Int = 30) {
//        let now = Date()
//        let calendar = Calendar.current
//        let demoLocations: [(Double, Double, String)] = [
//            (37.7749, -122.4194, "San Francisco"),
//            (34.0522, -118.2437, "Los Angeles"),
//            (40.7128, -74.0060, "New York"),
//            (47.6062, -122.3321, "Seattle"),
//            (51.5074, -0.1278, "London")
//        ]
//        entries = (0..<days).flatMap { dayOffset in
//            (0..<Int.random(in: 3...8)).map { _ in
//                let date = calendar.date(byAdding: .day, value: -dayOffset, to: now)!
//                
//                let valence = Double.random(in: -1...1)
//                let demoLocation = demoLocations.randomElement()!
//                
//                return MindStateEntry(
//                    timestamp: date,
//                    kind: Bool.random() ? .momentaryEmotion : .dailyMood,
//                    valence: valence,
//                    feelings: [],
//                    contexts: [],
//                    location: .init(
//                        latitude: demoLocation.0,
//                        longitude: demoLocation.1
//                    ),
//                    locationName: demoLocation.2
//                )
//            }
//        }
//        
//        entries = (0..<days).flatMap { dayOffset in
//            (0..<Int.random(in: 3...8)).map { _ in
//                let date = calendar.date(
//                    byAdding: .day,
//                    value: -dayOffset,
//                    to: now
//                )!
//                
//                return MindStateEntry(
//                    timestamp: date,
//                    kind: Bool.random() ? .momentaryEmotion : .dailyMood,
//                    valence: Double.random(in: -1...1),
//                    feelings: [],
//                    contexts: [],
//                    location: nil,
//                    locationName: nil
//                )
//            }
//        }
//    }
//#endif
//}
//
