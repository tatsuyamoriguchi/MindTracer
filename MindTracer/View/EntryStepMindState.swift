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
    
    var body: some View {
        Form {
            Picker("Kind", selection: $kind) {
                Text("Momentary Emotion").tag(MindStateKind.momentaryEmotion)
                Text("Daily Mood").tag(MindStateKind.dailyMood)
            }
            .pickerStyle(.segmented)
            
            // MARK: - Valence
            Section("Valence") {
                VStack(alignment: .leading, spacing: 8) {
                    Slider(value: $valence, in: -1.0...1.0, step: 0.01)
                    
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
                
                store.add(entry)

                print("New MindStateEntry:", entry)
                showEntrySheet = false
            }
        }
        .navigationTitle("Mind State")
        .navigationBarTitleDisplayMode(.inline)
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

