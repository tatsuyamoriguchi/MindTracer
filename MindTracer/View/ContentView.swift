import SwiftUI

struct ContentView: View {
    var body: some View {
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
    }
}



