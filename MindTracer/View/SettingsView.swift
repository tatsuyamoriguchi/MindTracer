//
//  SettingsView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var settings: NotificationSettings = NotificationSettingsStorage.shared.load()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    
                    Section(header: Text("Hourly Mind State Reminder")) {
                        Toggle("Enable", isOn: $settings.hourlyReminderEnabled)
                        Picker("Minute", selection: $settings.hourlyReminderMinute) {
                            ForEach(0..<60) { Text("\($0) min") }
                        }
                        TextField("Title", text: $settings.hourlyTitle)
                        TextField("Body", text: $settings.hourlyBody)
                        Picker("Sound", selection: $settings.hourlySound) {
                            Text("Default").tag("default")
                            Text("Chime").tag("chime")
                            Text("Bell").tag("bell")
                        }
                    }
                    
                    Section(header: Text("Hourly Task Reminder")) {
                        Toggle("Enable", isOn: $settings.hourlyTaskReminderEnabled)
                        Picker("Minute", selection: $settings.hourlyTaskReminderMinute) {
                            ForEach(0..<60) { Text("\($0) min") }
                        }
                        TextField("Title", text: $settings.hourlyTaskTitle)
                        TextField("Body", text: $settings.hourlyTaskBody)
                        Picker("Sound", selection: $settings.hourlyTaskSound) {
                            Text("Default").tag("default")
                            Text("Chime").tag("chime")
                            Text("Bell").tag("bell")
                        }
                    }
                    
                    Section(header: Text("Daily Reminder")) {
                        Toggle("Enable", isOn: $settings.dailyReminderEnabled)
                        DatePicker(
                            "Time",
                            selection: Binding(
                                get: {
                                    Calendar.current.date(from: DateComponents(hour: settings.dailyHour, minute: settings.dailyMinute)) ?? Date()
                                },
                                set: { date in
                                    let comps = Calendar.current.dateComponents([.hour, .minute], from: date)
                                    settings.dailyHour = comps.hour ?? 20
                                    settings.dailyMinute = comps.minute ?? 0
                                }
                            ),
                            displayedComponents: [.hourAndMinute]
                        )
                        TextField("Title", text: $settings.dailyTitle)
                        TextField("Body", text: $settings.dailyBody)
                        Picker("Sound", selection: $settings.dailySound) {
                            Text("Default").tag("default")
                            Text("Chime").tag("chime")
                            Text("Bell").tag("bell")
                        }
                    }
                    
                    Section(header: Text("Legal & Medical Disclaimer")) {
                        Text(MindTracerLegalContents().legal)
                    }
                    Section(header: Text("Copyright")) {
                        Text(MindTracerLegalContents().copyright)
                    }
                    Section(header: Text("Contact")) {
                        Text(MindTracerLegalContents().contact)
                    }
                }
                .onChange(of: settings) {
                    NotificationSettingsStorage.shared.save(settings)
                }
            }
            .navigationTitle("Settings")
        }

    }
}


#Preview {
    SettingsView()
}
