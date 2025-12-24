//
//  NotificationSettings.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/22/25.
//

import Foundation

struct NotificationSettings: Codable, Equatable {
    
    // Hourly reminders
    var hourlyReminderEnabled: Bool
    var hourlyMindStartHour: Int
    var hourlyMindEndHour: Int
    var hourlyReminderMinute: Int
    var hourlyTitle: String
    var hourlyBody: String
    var hourlySound: String // system sound name or "default"

    // Hourly task reminders
    var hourlyTaskReminderEnabled: Bool
    var hourlyTaskStartHour: Int
    var hourlyTaskEndHour: Int
    var hourlyTaskReminderMinute: Int
    var hourlyTaskTitle: String
    var hourlyTaskBody: String
    var hourlyTaskSound: String

    // Daily reminders
    var dailyReminderEnabled: Bool
    var dailyHour: Int
    var dailyMinute: Int
    var dailyTitle: String
    var dailyBody: String
    var dailySound: String
    
}

extension NotificationSettings {

    var summaryText: String {
        let summaries = [
            hourlySummary,
            hourlyTaskSummary,
            dailySummary
        ]

        // If everything is off
        if summaries.allSatisfy({ $0.contains("Off") }) {
            return "All reminders are off"
        }

        return summaries.joined(separator: "\n")
    }

    // MARK: - Individual summaries

    private var hourlySummary: String {
        guard hourlyReminderEnabled else {
            return "\(hourlyTitle): Off"
        }

        return "\(hourlyTitle): Every hour at \(hourlyReminderMinute) min"
    }

    private var hourlyTaskSummary: String {
        guard hourlyTaskReminderEnabled else {
            return "\(hourlyTaskTitle): Off"
        }

        return "\(hourlyTaskTitle): at \(hourlyTaskReminderMinute) min of hour"
    }

    private var dailySummary: String {
        guard dailyReminderEnabled else {
            return "\(dailyTitle): Off"
        }

        return "\(dailyTitle): \(formattedDailyTime)"
    }

    // MARK: - Helpers

    private var formattedDailyTime: String {
        let hour = dailyHour % 12 == 0 ? 12 : dailyHour % 12
        let period = dailyHour < 12 ? "AM" : "PM"
        let minute = String(format: "%02d", dailyMinute)

        return "\(hour):\(minute) \(period)"
    }
}


