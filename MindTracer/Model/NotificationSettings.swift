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
    var hourlyReminderMinute: Int
    var hourlyTitle: String
    var hourlyBody: String
    var hourlySound: String // system sound name or "default"

    // Hourly task reminders
    var hourlyTaskReminderEnabled: Bool
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

