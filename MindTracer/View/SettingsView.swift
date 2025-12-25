//
//  SettingsView.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/14/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var settings: NotificationSettings = NotificationSettingsStorage.shared.load()
    @AppStorage("notificationsEnabled") private var scheduledNotificationsEnabled = false // The default value (false) is used ONLY if the key does not exist
    @EnvironmentObject var permissionState: NotificationPermissionState
    // Read the agreement status from UserDefaults
    @AppStorage("legalAgreed") private var legalAgreed: Bool = false
    @AppStorage("legalAgreedDate") private var legalAgreedDate: Date?
    @Environment(\.openURL) private var openURL

    
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
                    }
                    
                    Section(header: Text("Reminder Settings")) {
                        // Toggle to cancel all scheduled notifications
                        Toggle("Enable Scheduled Notifications",
                               isOn: $scheduledNotificationsEnabled)
                        .onChange(of: scheduledNotificationsEnabled) { oldValue, newValue in
                            if newValue {
                                NotificationManager.shared.enableNotifications { granted in
                                    DispatchQueue.main.async {
                                        if granted {
                                            scheduledNotificationsEnabled = true
                                        } else {
                                            // Revert toggle if permission not granted
                                            scheduledNotificationsEnabled = false
                                        }
                                        permissionState.refresh()
                                    }
                                }
                            } else {
                                NotificationManager.shared.cancelAllNotifications()
                            }
                        }
                        
                        
                        
                        if !permissionState.isDeviceNotificationPermitted {
                            
                            Text("Notifications not permitted on this device.")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                            
                        } else if !scheduledNotificationsEnabled {
                            
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
                    .onAppear {
                        permissionState.refresh()
                        if scheduledNotificationsEnabled  &&
                            permissionState.isDeviceNotificationPermitted {
                            NotificationManager.shared.ensureScheduledNotifications()
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
                        HStack {
                            Text("Web: \(MindTracerLegalContents().webSite)")
                            Button {
                                openWeb()
                            } label: {
                                Image(systemName: "globe")
                            }
                        }
                        HStack {
                            Text(MindTracerLegalContents().email)
                            Button {
                                sendEmail()
                            } label: {
                                Image(systemName: "envelope")
                            }
                        }
                    }
                }
                .onChange(of: settings) {
                    NotificationSettingsStorage.shared.save(settings)
                }
            }
            .navigationTitle("Settings")
        }
        
    }
    private func openWeb() {
        guard let url = URL(string: MindTracerLegalContents().webSite) else {
            return
        }
        openURL(url)
    }

    
    private func sendEmail() {
        let subject = "Mind Tracer Inquiry"
        let body =
    """
    My question:
    """
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "mailto:support@modalflo.com?subject=\(encodedSubject)&body=\(encodedBody)"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
}


#Preview {
    SettingsView()
        .environmentObject(NotificationPermissionState())
}
