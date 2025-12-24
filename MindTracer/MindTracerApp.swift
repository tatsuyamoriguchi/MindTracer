//
//  MindTracerApp.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 11/7/25.
//

import SwiftUI

@main
struct MindTracerApp: App {
    @StateObject private var store = MindStateStore()
    @StateObject private var permissionState = NotificationPermissionState()
    @UIApplicationDelegateAdaptor(NotificationDelegate.self) var notificationDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(permissionState)
        }
    }
}

