//
//  NotificationDelegate.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/22/25.
//

import UIKit
import UserNotifications

class NotificationDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    // Called when app finishes launching
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Show notifications while app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

