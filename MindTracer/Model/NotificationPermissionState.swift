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
    
    func refresh() {
        NotificationManager.shared.getAuthorizationStatus { status in
            DispatchQueue.main.async {
                self.isDeviceNotificationPermitted =
                    (status == .authorized || status == .provisional)
            }
        }
    }
}
