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
                        Toggle("Permit Notifications on this Device", isOn: $notificationsEnabled)
                            .disabled(!permissionState.canRequestPermission) // disable if denied
                            .onChange(of: notificationsEnabled) { newValue in
                                guard newValue else {
                                    NotificationManager.shared.cancelAllNotifications()
                                    permissionState.isDeviceNotificationPermitted = false
                                    return
                                }

                                NotificationManager.shared.enableNotifications { granted in
                                    DispatchQueue.main.async {
                                        notificationsEnabled = granted
                                        permissionState.isDeviceNotificationPermitted = granted
                                    }
                                }
                            }

                        if !permissionState.canRequestPermission {
                            Text("Notifications are blocked. Please enable them in iOS Settings.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                        
//                        Toggle("Permit Notifications on this Device", isOn: $notificationsEnabled)
//                            .disabled(!permissionState.canRequestPermission)
//                            .onChange(of: notificationsEnabled) { oldValue, newValue in
//                                guard newValue else {
//                                    NotificationManager.shared.cancelAllNotifications()
//                                    permissionState.isDeviceNotificationPermitted = false
//                                    return
//                                }
//                                
//                                NotificationManager.shared.enableNotifications { granted in
//                                    DispatchQueue.main.async {
//                                        notificationsEnabled = granted
//                                        permissionState.isDeviceNotificationPermitted = granted
//                                    }
//                                }
//                                
//                                //                                if newValue {
//                                //                                    // Request notifications permission
//                                //                                    NotificationManager.shared.enableNotifications { granted in
//                                //                                        DispatchQueue.main.async {
//                                //                                            // Update toggle based on actual system permission
//                                //                                            notificationsEnabled = granted
//                                //                                            permissionState.isDeviceNotificationPermitted = granted
//                                //                                        }
//                                //                                    }
//                                //                                } else {
//                                //                                    NotificationManager.shared.cancelAllNotifications()
//                                //                                    permissionState.isDeviceNotificationPermitted = false
//                                //                                }
//                                
//                                //                                if newValue {
//                                //                                    NotificationManager.shared.enableNotifications()
//                                //
//                                //                                } else {
//                                //                                    NotificationManager.shared.cancelAllNotifications()
//                                //                                }
//                                                                
//                                // 🔑 FORCE UI STATE UPDATE
////                                permissionState.isDeviceNotificationPermitted = newValue
//                                
//                            }
                    }
                    .onAppear {
                        permissionState.refresh()
                        notificationsEnabled = permissionState.isDeviceNotificationPermitted
                    }
                    .onChange(of: permissionState.isDeviceNotificationPermitted) { _, newValue in
                        notificationsEnabled = newValue
                    }
                    
                    Section(header: Text("Reminder Settings")) {
                        
                        if permissionState.isDeviceNotificationPermitted == true {
                            
                            Text(settings.summaryText)
                                .font(.caption)
                                .foregroundColor(.primary)
                            
                            NavigationLink("To Reminder Settings") {
                                ReminderView(settings: $settings)
                            }
                            
                        } else {
                            
                            Text("Notifications not permitted on this device.")
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
