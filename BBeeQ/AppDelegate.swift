import BBQProbeE
import Combine
import CoreBluetooth
import SwiftData
import SwiftUI
import UserNotifications
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Main")

// TODO: Add back activity, notification
#if os(macOS)
  class AppDelegate: NSObject, NSApplicationDelegate, ProbePeripheralDelegate {
    public var probePeripheralManager: ProbePeripheralManager!

    override init() {
      super.init()
      self.probePeripheralManager = ProbePeripheralManager(
        delegate: self, queue: DispatchQueue.main)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
      logger.info("Started RSSBar")
      DispatchQueue.main.async {
        NSApp.setActivationPolicy(.accessory)
      }
    }

    func probePeripheralManager(didDiscover peripheral: CBPeripheral) {
      // TODO: Auto connect (like was done before)
    }
  }
#endif

// TODO: Add back activity, notification
#if os(iOS)
  class AppDelegate: NSObject, UIApplicationDelegate, ProbePeripheralDelegate {
    public var probePeripheralManager: ProbePeripheralManager!

    override init() {
      super.init()
      self.probePeripheralManager = ProbePeripheralManager(
        delegate: self, queue: DispatchQueue.main)
    }

    func application(
      _: UIApplication,
      didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      logger.info("Started RSSBar")
      print("Started")

      return true
    }

    func probePeripheralManager(didDiscover peripheral: CBPeripheral) {
      // TODO: Auto connect (like was done before)
    }
  }
#endif
