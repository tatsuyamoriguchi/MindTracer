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
        
        entries = (0..<days).flatMap { dayOffset in
            (0..<Int.random(in: 3...8)).map { _ in
                let date = calendar.date(
                    byAdding: .day,
                    value: -dayOffset,
                    to: now
                )!
                
                return MindStateEntry(
                    timestamp: date,
                    kind: Bool.random() ? .momentaryEmotion : .dailyMood,
                    valence: Double.random(in: -1...1),
                    feelings: [],
                    contexts: [],
                    location: nil,
                    locationName: nil
                )
            }
        }
    }
#endif
    
}
