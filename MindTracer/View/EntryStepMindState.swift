//
//  EntryStepMindState.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//


import SwiftUI
import CoreLocation

struct EntryStepMindState: View {
    @Binding var kind: MindStateKind
    @Binding var valence: Double
    @Binding var labels: Set<MindFeeling>
    @Binding var associations: Set<MindContext>
    @Binding var timestamp: Date
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var showEntrySheet: Bool
    @Binding var locationName: String?
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var store: MindStateStore
    
    // Map each feeling to a valence value
    private let feelingValenceMap: [MindFeeling: Double] = [
        .happy: 1.0,
        .excited: 0.9,
        .content: 0.5,
        .calm: 0.2,
        .tired: -0.1,
        .lonely: -0.3,
        .anxious: -0.5,
        .stressed: -0.7,
        .sad: -0.8,
        .angry: -1.0,
        .neutral: 0.0
        // Add more as needed
    ]
    
    var body: some View {
        Form {
            Picker("Kind", selection: $kind) {
                Text("Momentary Emotion").tag(MindStateKind.momentaryEmotion)
                Text("Daily Mood").tag(MindStateKind.dailyMood)
            }
            .pickerStyle(.segmented)
            
            // MARK: - Valence (Read-only)
            Section("Valence") {
                VStack(alignment: .leading, spacing: 8) {
                    // Display valence without user interaction
                    Slider(value: Binding.constant(computedValence), in: -1.0...1.0)
                        .disabled(true) // make read-only
                        .accentColor(.blue)
                    
                    HStack {
                        Text("Unpleasant")
                        Spacer()
                        Text("Pleasant")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    
                    Text(valenceClassification.rawValue.capitalized)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Labels") {
                ForEach(MindFeeling.allCases, id: \.self) { feeling in
                    Toggle(feeling.rawValue.capitalized, isOn: Binding(
                        get: { labels.contains(feeling) },
                        set: { isOn in
                            if isOn { labels.insert(feeling) } else { labels.remove(feeling) }
                            // Update valence whenever labels change
                            valence = computedValence
                        }
                    ))
                }
            }
            
            Section("Associations") {
                ForEach(MindContext.allCases, id: \.self) { context in
                    Toggle(context.rawValue.capitalized, isOn: Binding(
                        get: { associations.contains(context) },
                        set: { isOn in
                            if isOn { associations.insert(context) } else { associations.remove(context) }
                        }
                    ))
                }
            }
            
            Button("Save Entry") {
                let entry = MindStateEntry(
                    timestamp: timestamp,
                    kind: kind,
                    valence: valence,
                    feelings: Array(labels),
                    contexts: Array(associations),
                    location: coordinate, locationName: locationName
                )
                
                withAnimation {
                    store.add(entry)       // triggers view update
                    showEntrySheet = false // dismiss sheet
                }
                
            }
        }
        .navigationTitle("Mind State")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Compute valence based on selected labels
    private var computedValence: Double {
        guard !labels.isEmpty else { return 0.0 }
        let sum = labels.compactMap { feelingValenceMap[$0] }.reduce(0, +)
        return sum / Double(labels.count)
    }
    
    private var valenceClassification: ValenceClassification {
        switch valence {
        case ..<(-0.6): return .veryUnpleasant
        case -0.6..<(-0.2): return .unpleasant
        case -0.2...0.2: return .neutral
        case 0.2...0.6: return .pleasant
        default: return .veryPleasant
        }
    }
}

//import SwiftUI
//import CoreLocation
//
//struct EntryStepMindState: View {
//    @Binding var kind: MindStateKind
//    @Binding var valence: Double
//    @Binding var labels: Set<MindFeeling>
//    @Binding var associations: Set<MindContext>
//    @Binding var timestamp: Date
//    @Binding var coordinate: CLLocationCoordinate2D?
//    @Binding var showEntrySheet: Bool
//    @Binding var locationName: String?
//    
//    @Environment(\.dismiss) private var dismiss
//    @EnvironmentObject var store: MindStateStore
//    
//    var body: some View {
//        Form {
//            Picker("Kind", selection: $kind) {
//                Text("Momentary Emotion").tag(MindStateKind.momentaryEmotion)
//                Text("Daily Mood").tag(MindStateKind.dailyMood)
//            }
//            .pickerStyle(.segmented)
//            
//            // MARK: - Valence
//            Section("Valence") {
//                VStack(alignment: .leading, spacing: 8) {
//                    Slider(value: $valence, in: -1.0...1.0, step: 0.01)
//                    
//                    HStack {
//                        Text("Unpleasant")
//                        Spacer()
//                        Text("Pleasant")
//                    }
//                    .font(.caption)
//                    .foregroundStyle(.secondary)
//                    
//                    Text(valenceClassification.rawValue.capitalized)
//                        .font(.headline)
//                        .foregroundStyle(.secondary)
//                }
//                .padding(.vertical, 4)
//            }
//            
//            Section("Labels") {
//                ForEach(MindFeeling.allCases, id: \.self) { feeling in
//                    Toggle(feeling.rawValue.capitalized, isOn: Binding(
//                        get: { labels.contains(feeling) },
//                        set: { isOn in
//                            if isOn { labels.insert(feeling) } else { labels.remove(feeling) }
//                        }
//                    ))
//                }
//            }
//            
//            Section("Associations") {
//                ForEach(MindContext.allCases, id: \.self) { context in
//                    Toggle(context.rawValue.capitalized, isOn: Binding(
//                        get: { associations.contains(context) },
//                        set: { isOn in
//                            if isOn { associations.insert(context) } else { associations.remove(context) }
//                        }
//                    ))
//                }
//            }
//            
//            Button("Save Entry") {
//                let entry = MindStateEntry(
//                    timestamp: timestamp,
//                    kind: kind,
//                    valence: valence,
//                    feelings: Array(labels),
//                    contexts: Array(associations),
//                    location: coordinate, locationName: locationName
//                )
//                
//                store.add(entry)
//
//                print("New MindStateEntry:", entry)
//                showEntrySheet = false
//            }
//            Text("You could have valence = 0.3 → pleasant But MindFeeling might include [happy, anxious] The user feels both happy and a little anxious. Valence gives the overall \"pleasantness\", but feelings capture nuance. They don't strictly conflict — even though unpleasant and happy seem opposite, a user might have mixed emotions. Valence is continuous; feelings are tags.")
//                .font(.caption)
//        }
//        .navigationTitle("Mind State")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//    
//    private var valenceClassification: ValenceClassification {
//        switch valence {
//        case ..<(-0.6): return .veryUnpleasant
//        case -0.6..<(-0.2): return .unpleasant
//        case -0.2...0.2: return .neutral
//        case 0.2...0.6: return .pleasant
//        default: return .veryPleasant
//        }
//    }
//}
//
