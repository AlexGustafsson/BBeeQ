import SwiftUI

struct AppView: View {
  @State private var selectedTab: String = ""

  var body: some View {
    TabView(selection: $selectedTab) {
      ProbesView()
        .tabItem {
          Label("Thermometer", systemImage: "thermometer.medium")
        }

      ChartsView()
        .tabItem {
          Label("Charts", systemImage: "chart.xyaxis.line")
        }
      SettingsView()
        .tabItem {
          Label("Settings", systemImage: "gearshape")
        }
    }
  }
}
