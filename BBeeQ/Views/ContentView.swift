//
//  ContentView.swift
//  BBeeQ
//
//  Created by Alex Gustafsson on 2025-08-01.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
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

#Preview {
  ContentView()
    .modelContainer(for: Probe.self, inMemory: true)
}
