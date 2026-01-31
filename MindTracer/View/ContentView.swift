import SwiftUI

struct ContentView: View {
    @AppStorage("legalAgreed") private var legalAgreed: Bool = false
    @AppStorage("legalAgreedDate") private var legalAgreedDate: Date?
    
    
    var body: some View {
        if legalAgreed {
            
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                
                MapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                
                AnalysisView()
                    .tabItem {
                        Label("Analysis", systemImage: "chart.xyaxis.line")
                    }
                
                InfoView()
                    .tabItem {
                        Label("Info", systemImage: "info.circle")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                
            }
            
        } else {
            // Handle the agreement here, at top-level
            LegalView {
                legalAgreed = true
                UserDefaults.standard.set(true, forKey: "legalAgreed")
                
                // Save the timestamp
                let now = Date()
                UserDefaults.standard.set(now, forKey: "legalAgreedDate")
            }

        }
    }
}



