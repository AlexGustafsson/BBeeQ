import BBQProbeE
import Combine
import CoreBluetooth
import SwiftData
import SwiftUI
import UserNotifications
import os

#if os(macOS)
  @main struct BBeeQ: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
      WindowGroup {
        AppView()
          .modelContainer(appDelegate.modelContainer)
          .environment(
            \.probePeripheralManager, appDelegate.probePeripheralManager)
      }
    }
  }
#endif

#if os(iOS)
  @main struct BBeeQ: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
      WindowGroup {
        AppView()
          .modelContainer(appDelegate.modelContainer)
          .environment(
            \.probePeripheralManager, appDelegate.probePeripheralManager)
      }
    }
  }
#endif
