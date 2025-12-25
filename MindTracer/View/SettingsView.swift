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
    // Read the agreement status from UserDefaults
    @AppStorage("legalAgreed") private var legalAgreed: Bool = false
    @AppStorage("legalAgreedDate") private var legalAgreedDate: Date?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Form {
                    Section {
                        // Show system permission status
                        if permissionState.isDeviceNotificationPermitted {
                            Text("✅ Notifications are enabled on this device.")
                                .foregroundColor(.green)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("⚠️ Notifications are blocked. Please enable them in iOS Settings.")
                                    .foregroundColor(.red)
                                Button("Open Settings") {
                                    if let url = URL(string: UIApplication.openSettingsURLString),
                                       UIApplication.shared.canOpenURL(url) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .font(.footnote)
                            }
                        }
                        
                        // Toggle to cancel all scheduled notifications
                        Toggle("Enable Scheduled Notifications", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { oldValue, newValue in
                                if newValue {
                                    // Re-schedule notifications based on saved settings
                                    NotificationManager.shared.enableNotifications { granted in
                                        DispatchQueue.main.async {
                                            // Only update scheduled notifications toggle, not system permission
                                            notificationsEnabled = true
                                        }
                                    }
                                } else {
                                    NotificationManager.shared.cancelAllNotifications()
                                }
                            }
                    }

                    .onAppear {
                        permissionState.refresh()
                        notificationsEnabled = permissionState.isDeviceNotificationPermitted
                    }

                    Section(header: Text("Reminder Settings")) {

                        if !permissionState.isDeviceNotificationPermitted {

                            Text("Notifications not permitted on this device.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)

                        } else if !notificationsEnabled {

                            Text("Scheduled notifications are disabled.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)

                        } else {

                            Text(settings.summaryText)
                                .font(.caption)
                                .foregroundColor(.primary)

                            NavigationLink("To Reminder Settings") {
                                ReminderView(settings: $settings)
                            }
                        }
                    }

                    
                    Section(header: Text("Version & Build Info")) {
                        Text(AppVersion.fullVersion)
                    }
                    
                    Section(header: Text("Legal & Medical Disclaimer")) {
                        Text(MindTracerLegalContents().legal)
                        // Show agreement status
                        if legalAgreed {
                            Text("✅ You have agreed to the legal statement.")
                                .foregroundColor(.green)
                                .font(.footnote)
                            if let date = legalAgreedDate {
                                Text("Agreed on: \(date.formatted(date: .long, time: .shortened))")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            }
                        } else {
                            Text("⚠️ You have not agreed to the legal statement yet.")
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
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
