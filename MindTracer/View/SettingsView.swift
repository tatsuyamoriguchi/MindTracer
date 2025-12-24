//
//  SettingsView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var settings: NotificationSettings = NotificationSettingsStorage.shared.load()
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false // The default value (false) is used ONLY if the key does not exist
    @EnvironmentObject var permissionState: NotificationPermissionState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        Toggle("Permit Notifications on this Device", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { oldValue, newValue in
                                if newValue {
                                    NotificationManager.shared.enableNotifications()
                                } else {
                                    NotificationManager.shared.cancelAllNotifications()
                                }
                                // 🔑 FORCE UI STATE UPDATE
                                    permissionState.isDeviceNotificationPermitted = newValue
                            }
                    }
                    .onAppear {
                        permissionState.refresh()
                        notificationsEnabled = permissionState.isDeviceNotificationPermitted
                    }
                    .onChange(of: permissionState.isDeviceNotificationPermitted) { _, newValue in
                        notificationsEnabled = newValue
                    }

//                    Section(header: Text("Reminder Settings")) {
//
//                        Text(settings.summaryText)
//                            .font(.caption)
//                                .foregroundColor(.primary)
//                        
//                        NavigationLink("To Reminder Settings") {
//                            ReminderView(settings: $settings)
//                        }
//                    }
                    Section(header: Text("Reminder Settings")) {

                        if permissionState.isDeviceNotificationPermitted {

                            Text(settings.summaryText)
                                .font(.caption)
                                .foregroundColor(.primary)

                            NavigationLink("To Reminder Settings") {
                                ReminderView(settings: $settings)
                            }

                        } else {

                            Text("Notifications not permitted on this device.\nEnable it above.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .padding(.vertical, 4)
                        }
                    }

                    
                    
                    Section(header: Text("Version & Build Info")) {
                        Text(AppVersion.fullVersion)
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
