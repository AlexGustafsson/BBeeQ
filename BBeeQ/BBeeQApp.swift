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

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(appDelegate.sharedModelContainer)
    .environment(
      \.probePeripheralManager, appDelegate.probePeripheralManager
    )
    .environment(\.historyManager, appDelegate.historyManager)
  }
}
