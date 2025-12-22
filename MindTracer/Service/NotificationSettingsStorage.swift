//
//  NotificationSettingsStorage.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/22/25.
//

import Foundation

class NotificationSettingsStorage {
    
    static let shared = NotificationSettingsStorage()
    private init() {}
    
    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("NotificationSettings.json")
    }
    
    // Save settings
    func save(_ settings: NotificationSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            try data.write(to: fileURL)
            print("Notification settings saved to JSON")
        } catch {
            print("Error saving settings: \(error)")
        }
    }
    
    // Load settings, or return default if none
    func load() -> NotificationSettings {
        do {
            let data = try Data(contentsOf: fileURL)
            let settings = try JSONDecoder().decode(NotificationSettings.self, from: data)
            return settings
        } catch {
            print("No saved settings found, using defaults. Error: \(error)")
            return defaultSettings()
        }
    }
    
    private func defaultSettings() -> NotificationSettings {
        return NotificationSettings(
            hourlyReminderEnabled: true,
            hourlyReminderMinute: 50,
            hourlyTitle: "Mind Tracer Reminder",
            hourlyBody: "Take a moment to log your Mind State.",
            hourlySound: "default",
            hourlyTaskReminderEnabled: true,
            hourlyTaskReminderMinute: 0,
            hourlyTaskTitle: "Task Reminder",
            hourlyTaskBody: "Start your next task now.",
            hourlyTaskSound: "default",
            dailyReminderEnabled: true,
            dailyHour: 20,
            dailyMinute: 0,
            dailyTitle: "Daily Mind Check",
            dailyBody: "How are you feeling today?",
            dailySound: "default"
        )
    }
}
