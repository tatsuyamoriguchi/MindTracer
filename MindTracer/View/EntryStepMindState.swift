//
//  EntryStepMindState.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/15/25.
//

import SwiftUI

struct EntryStepMindState: View {
    @Binding var kind: MindStateKind
    @Binding var valence: Double
    @Binding var labels: Set<MindFeeling>
    @Binding var associations: Set<MindContext>
    
    var body: some View {
        Form {
            Picker("Kind", selection: $kind) {
                Text("Momentary Emotion").tag(MindStateKind.momentaryEmotion)
                Text("Daily Mood").tag(MindStateKind.dailyMood)
            }
            
            Slider(value: $valence, in: -1.0...1.0, step: 0.01) {
                Text("Valence")
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
        }
        .navigationTitle("Mind State")
    }
}

