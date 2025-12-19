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
        
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

