//
//  NotificationManager.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/22/25.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    
    private init() {} // singleton
    
    // MARK: - Request Permission
    func requestPermission(completion: ((Bool) -> Void)? = nil) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
                completion?(false)
            } else {
                print("Notification permission granted: \(granted)")
                completion?(granted)
            }
        }
    }
    
    // MARK: - Schedule Notifications
    
    // Repeating every X hours
    func scheduleRepeatingNotification(settings: NotificationSettings, intervalHours: Int, title: String, body: String, identifier: String) {
        guard intervalHours > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = settings.hourlyTitle
        content.body = settings.hourlyBody
        content.sound = settings.hourlySound == "default" ? .default : UNNotificationSound(named: UNNotificationSoundName(settings.hourlySound))

        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(intervalHours * 3600), repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling repeating notification: \(error)")
            } else {
                print("Repeating notification scheduled: \(identifier)")
            }
        }
    }
    
    
    // Schedule hourly notification
    func scheduleHourlyNotification(atMinute minute: Int, identifier: String, title: String, body: String, hourlySound: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        // Schedule for every hour at the selected minute
        for hour in 0..<24 {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: "\(identifier)_\(hour)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling hourly notification for hour \(hour): \(error)")
                }
            }
        }
    }

    
    
    // Daily at a specific time
    func scheduleDailyNotification(hour: Int, minute: Int, title: String, body: String, sound: String, identifier: String) {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily notification: \(error)")
            } else {
                print("Daily notification scheduled at \(hour):\(minute)")
            }
        }
    }
    
    // Cancel one notification
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Helper: Enable notifications with predefined schedules
    func enableNotifications() {
        requestPermission { granted in
            guard granted else { return }
            
            // Load user's saved notification settings from JSON
            let settings = NotificationSettingsStorage.shared.load()
            
            // Schedule hourly Mind State reminder
            if settings.hourlyReminderEnabled {
                self.scheduleHourlyNotification(
                    atMinute: settings.hourlyReminderMinute,
                    identifier: "hourlyReminder",
                    title: settings.hourlyTitle,
                    body: settings.hourlyBody,
                    hourlySound: settings.hourlySound
                )
            }

            // Schedule hourly Task reminder
            if settings.hourlyTaskReminderEnabled {
                self.scheduleHourlyNotification(
                    atMinute: settings.hourlyTaskReminderMinute,
                    identifier: "hourlyTaskReminder",
                    title: settings.hourlyTaskTitle,
                    body: settings.hourlyTaskBody,
                    hourlySound: settings.hourlyTaskSound
                )
            }

            // Schedule daily reminder
            if settings.dailyReminderEnabled {
                self.scheduleDailyNotification(
                    hour: settings.dailyHour,
                    minute: settings.dailyMinute,
                    title: settings.dailyTitle,
                    body: settings.dailyBody,
                    sound: settings.dailySound,
                    identifier: "dailyReminder"
                )
            }
        }
    }

}
