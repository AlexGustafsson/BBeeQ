//
//  BBeeQApp.swift
//  BBeeQ
//
//  Created by Alex Gustafsson on 2025-08-01.
//

import SwiftData
import SwiftUI

@main struct BBeeQApp: App {
  #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  #endif

  #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  #endif

  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Probe.self
    ])
    let modelConfiguration = ModelConfiguration(
      schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(
        for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
    .environment(
      \.probePeripheralManager, appDelegate.probePeripheralManager)
  }
}
