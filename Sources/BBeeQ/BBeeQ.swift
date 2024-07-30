import CoreBluetooth
import os
import BBQProbeE
import Combine
import SwiftUI
import SwiftData

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Main")

class AppDelegate: NSObject, NSApplicationDelegate {
  public let modelContainer: ModelContainer = try! ModelContainer.initDefault()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    logger.info("Started RSSBar")
    DispatchQueue.main.async {
      NSApp.setActivationPolicy(.accessory)
    }
  }
}

@main struct BBeeQ: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      AppView().modelContainer(appDelegate.modelContainer)
    }
  }
}
