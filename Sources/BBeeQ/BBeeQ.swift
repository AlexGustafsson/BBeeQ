import BBQProbeE
import Combine
import CoreBluetooth
import SwiftData
import SwiftUI
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Main")

#if os(macOS)
  class AppDelegate: NSObject, NSApplicationDelegate, ProbePeripheralDelegate {
    public let modelContainer: ModelContainer
    public var probePeripheralManager: ProbePeripheralManager!

    override init() {
      self.modelContainer = try! ModelContainer.initDefault()
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
      // TODO: Only show discovered, click once to connect. If the model is saved
      // as once connected - it will be remembered and auto-connected. Otherwise
      // the first connect is manual. Then have settings for forgetting /
      // disconnecting a probe
      // if peripheral.state == .disconnected {
      //   // TODO: Concurrency
      //   Task {
      //     logger.debug("Connecting to peripheral: \(peripheral.identifier, privacy: .public)")
      //     let probe = try await self.probePeripheralManager.connect(peripheral: peripheral)
      //     logger.debug("Connected to peripheral: \(probe.id, privacy: .public)")
      //     let context = ModelContext(self.modelContainer)
      //     // TODO: Upsert to keep values?
      //     // TODO: Name will always be nil here as we don't wait for
      //     // characteristics to be read
      //     context.insert(Probe(id: probe.id.uuidString, name: probe.deviceName ?? "", temperatureTarget: 65, grillTemperatureTarget: 300))
      //     try context.save()
      //   }
      // }
    }
  }

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
  import ActivityKit

  public struct ProbeActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
      public let probeTemperature: Double
      public let grillTemperature: Double

      public init(probeTemperature: Double, grillTemperature: Double) {
        self.probeTemperature = probeTemperature
        self.grillTemperature = grillTemperature
      }
    }

    public init() {

    }
  }

  class AppDelegate: NSObject, UIApplicationDelegate, ProbePeripheralDelegate {
    public let modelContainer: ModelContainer
    public var probePeripheralManager: ProbePeripheralManager!

    var activity: Activity<ProbeActivityAttributes>?

    override init() {
      self.modelContainer = try! ModelContainer.initDefault()
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

      let orderAttributes = ProbeActivityAttributes()
      let initialState = ProbeActivityAttributes.ContentState(
        probeTemperature: 45, grillTemperature: 120)
      let content = ActivityContent(
        state: initialState, staleDate: nil, relevanceScore: 1.0)

      do {
        logger.debug("Starting activity")
        self.activity = try Activity.request(
          attributes: orderAttributes,
          content: content,
          pushType: nil
        )
        logger.debug("Started activity")
      } catch {
        logger.error("Failed to start activity \(error, privacy: .public)")
        print("Failed")
      }
      return true
    }

    func probePeripheralManager(didDiscover peripheral: CBPeripheral) {
      // TODO: Only show discovered, click once to connect. If the model is saved
      // as once connected - it will be remembered and auto-connected. Otherwise
      // the first connect is manual. Then have settings for forgetting /
      // disconnecting a probe
      // if peripheral.state == .disconnected {
      //   // TODO: Concurrency
      //   Task {
      //     logger.debug("Connecting to peripheral: \(peripheral.identifier, privacy: .public)")
      //     let probe = try await self.probePeripheralManager.connect(peripheral: peripheral)
      //     logger.debug("Connected to peripheral: \(probe.id, privacy: .public)")
      //     let context = ModelContext(self.modelContainer)
      //     // TODO: Upsert to keep values?
      //     // TODO: Name will always be nil here as we don't wait for
      //     // characteristics to be read
      //     context.insert(Probe(id: probe.id.uuidString, name: probe.deviceName ?? "", temperatureTarget: 65, grillTemperatureTarget: 300))
      //     try context.save()
      //   }
      // }
    }
  }

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
