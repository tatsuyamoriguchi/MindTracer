//
//  MindStateStep.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//

import SwiftUI
import CoreLocation

struct MindStateStep: View {
    @Binding var kind: String
    @Binding var valence: Double
    @Binding var valenceClassification: String
    @Binding var labels: Set<MindFeeling>
    @Binding var associations: Set<MindContext>
    
    let timestamp: Date
    let coordinate: CLLocationCoordinate2D?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Kind") {
                Picker("Kind", selection: $kind) {
                    Text("Momentary Emotion").tag("momentaryEmotion")
                    Text("Daily Mood").tag("dailyMood")
                }
                .pickerStyle(.segmented)
            }
            
            Section("Valence") {
                Slider(value: $valence, in: -1.0...1.0, step: 0.01)
                Text("Valence Classification: \(valenceClassification)")
            }
            
            Section("Feelings") {
                ForEach(MindFeeling.allCases) { feeling in
                    Toggle(feeling.rawValue.capitalized, isOn: Binding(
                        get: { labels.contains(feeling) },
                        set: { newValue in
                            if newValue { labels.insert(feeling) } else { labels.remove(feeling) }
                        }
                    ))
                }
            }
            
            Section("Contexts") {
                ForEach(MindContext.allCases) { context in
                    Toggle(context.rawValue.capitalized, isOn: Binding(
                        get: { associations.contains(context) },
                        set: { newValue in
                            if newValue { associations.insert(context) } else { associations.remove(context) }
                        }
                    ))
                }
            }
            
            Button("Save Entry") {
                let entry = MindStateEntry(
                    timestamp: timestamp,
                    kind: kind == "momentaryEmotion" ? .momentaryEmotion : .dailyMood,
                    valence: valence,
                    feelings: Array(labels),
                    contexts: Array(associations),
                    location: coordinate
                )
                print("New MindStateEntry:", entry)
                dismiss()
            }
        }
        .navigationTitle("Mind State")
    }
}

