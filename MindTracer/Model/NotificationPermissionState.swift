//
//  NotificationPermissionState.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/23/25.
//

import Foundation

@MainActor
final class NotificationPermissionState: ObservableObject {
    @Published var isDeviceNotificationPermitted: Bool = false
    @Published var canRequestPermission: Bool = true
    
    func refresh() {
//        NotificationManager.shared.getAuthorizationStatus { status in
//            DispatchQueue.main.async {
//                self.isDeviceNotificationPermitted =
//                    (status == .authorized || status == .provisional)
//            }
//        }
        NotificationManager.shared.getAuthorizationStatus { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .notDetermined:
                            self.canRequestPermission = true
                            self.isDeviceNotificationPermitted = false
                        case .denied:
                            self.canRequestPermission = false
                            self.isDeviceNotificationPermitted = false
                        case .authorized, .provisional, .ephemeral:
                            self.canRequestPermission = true
                            self.isDeviceNotificationPermitted = true
                        @unknown default:
                            self.canRequestPermission = false
                            self.isDeviceNotificationPermitted = false
                        }
                    }
                }
    }
}
