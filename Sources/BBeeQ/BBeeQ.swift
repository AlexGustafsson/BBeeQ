import CoreBluetooth
import os
import BBQProbeE
import Combine
import SwiftUI
import SwiftData

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Main")

class AppDelegate: NSObject, NSApplicationDelegate, ProbePeripheralDelegate {
  public let modelContainer: ModelContainer
  public var probePeripheralManager: ProbePeripheralManager!;

  override init() {
    self.modelContainer = try! ModelContainer.initDefault()
    super.init()
    self.probePeripheralManager = ProbePeripheralManager(delegate: self, queue: DispatchQueue.main)
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    logger.info("Started RSSBar")
    DispatchQueue.main.async {
      NSApp.setActivationPolicy(.accessory)
    }
  }

  func probePeripheralManager(didDiscover peripheral: CBPeripheral) {
    // TODO: Only show discovered, click once to connect. If the model is saved
    // as once connected - it will be remembered and auto-connected. Otherwise
    // the first connect is manual. Then have settings for forgetting /
    // disconnecting a probe
    if peripheral.state == .disconnected {
      // TODO: Concurrency
      Task {
        logger.debug("Connecting to peripheral: \(peripheral.identifier, privacy: .public)")
        let probe = try await self.probePeripheralManager.connect(peripheral: peripheral)
        logger.debug("Connected to peripheral: \(probe.id, privacy: .public)")
        let context = ModelContext(self.modelContainer)
        // TODO: Upsert to keep values?
        // TODO: Name will always be nil here as we don't wait for
        // characteristics to be read
        context.insert(Probe(id: probe.id.uuidString, name: probe.deviceName ?? "", temperatureTarget: 65, grillTemperatureTarget: 300))
        try context.save()
      }
    }
  }
}

@main struct BBeeQ: App {
  @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

  var body: some Scene {
    WindowGroup {
      AppView()
        .modelContainer(appDelegate.modelContainer)
        .environment(\.probePeripheralManager, appDelegate.probePeripheralManager)
    }
  }
}
