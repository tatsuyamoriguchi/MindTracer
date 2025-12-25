//
//  ReminderView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/23/25.
//

import SwiftUI

struct ReminderView: View {
    @Binding var settings: NotificationSettings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button {
            NotificationManager.shared.enableNotifications { _ in }
            DispatchQueue.main.async {
                dismiss()
            }
        } label: {
            Text("Update Reminders")
        }
        .buttonStyle(PressableButtonStyle())
        
        Form {
            Section(content: {
                VStack {
                    Toggle("Enable", isOn: $settings.hourlyReminderEnabled)
                    
                    Picker("Minute", selection: $settings.hourlyReminderMinute) {
                        ForEach(0..<60) { Text("\($0) min") }
                    }
                    
                    HStack {
                        Text("Active From")
                        Spacer()
                        Picker("", selection: $settings.hourlyMindStartHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                let hour12 = hour % 12 == 0 ? 12 : hour % 12
                                let period = hour < 12 ? "am" : "pm"
                                Text("\(hour12) \(period)")
                            }
                        }
                        .frame(width: 120)
                        
                        Text("To")
                        Picker("", selection: $settings.hourlyMindEndHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                let hour12 = hour % 12 == 0 ? 12 : hour % 12
                                let period = hour < 12 ? "am" : "pm"
                                Text("\(hour12) \(period)")
                            }
                        }
                        .frame(width: 120)
                    }
                    
                    
                    TextField("Title", text: $settings.hourlyTitle)
                    TextField("Body", text: $settings.hourlyBody)
                    Picker("Sound", selection: $settings.hourlySound) {
                        Text("Default").tag("default")
                        Text("Chime").tag("chime")
                        Text("Bell").tag("bell")
                    }
                }
            }, header: {
                Text("Hourly Mind State Reminder")
            })
            
            Section(header: Text("Hourly Task Reminder")) {
                Toggle("Enable", isOn: $settings.hourlyTaskReminderEnabled)
                
                Picker("Minute", selection: $settings.hourlyTaskReminderMinute) {
                    ForEach(0..<60) { Text("\($0) min") }
                }
                
                HStack {
                    Text("Active From")
                    Spacer()
                    Picker("", selection: $settings.hourlyTaskStartHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            let hour12 = hour % 12 == 0 ? 12 : hour % 12
                            let period = hour < 12 ? "am" : "pm"
                            Text("\(hour12) \(period)")
                        }
                    }
                    .frame(width: 100)
                    
                    Text("To")
                    Picker("", selection: $settings.hourlyTaskEndHour) {
                        ForEach(0..<24, id: \.self) { hour in
                            let hour12 = hour % 12 == 0 ? 12 : hour % 12
                            let period = hour < 12 ? "am" : "pm"
                            Text("\(hour12) \(period)")
                        }
                    }
                    .frame(width: 80)
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
            
        }
        
    }
}


//#Preview {
//    @Binging sampleSettings = NotificationSettings(hourlyReminderEnabled: true, hourlyReminderMinute: 06, hourlyTitle: "Hello Test", hourlyBody: "Hello Aloha", hourlySound: "default", hourlyTaskReminderEnabled: true, hourlyTaskReminderMinute: 07, hourlyTaskTitle: "Hourly Task Reminder", hourlyTaskBody: "Hello Hello Hello", hourlyTaskSound: "default", dailyReminderEnabled: true, dailyHour: 16, dailyMinute: 08, dailyTitle: "Daily Reminder", dailyBody: "Hello Aloha Hola", dailySound: "default")
//    ReminderView(settings: $sampleSettings)
//}
