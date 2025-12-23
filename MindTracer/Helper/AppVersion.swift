//
//  AppVersion.swift
//  MindTracer
//
//  Created by Tatsuya Moriguchi on 12/22/25.
//

import Foundation

struct AppVersion {
    static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    static var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    static var fullVersion: String {
        "Version \(version) Build (\(build))"
    }
}
