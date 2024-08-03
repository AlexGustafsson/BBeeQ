import BBQProbeE
import Combine
import CoreBluetooth
import SwiftData
import SwiftUI
import UserNotifications
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Main")

#if os(macOS)
  class AppDelegate: NSObject, NSApplicationDelegate, ProbePeripheralDelegate {
    public let modelContainer: ModelContainer
    public var probePeripheralManager: ProbePeripheralManager!
    private var alerter: TemperatureAlerter!

    override init() {
      self.modelContainer = try! ModelContainer.initDefault()
      super.init()
      self.probePeripheralManager = ProbePeripheralManager(
        delegate: self, queue: DispatchQueue.main)
      self.alerter = TemperatureAlerter(
        probePeripheralManager: probePeripheralManager,
        modelContainer: modelContainer)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
      logger.info("Started RSSBar")
      DispatchQueue.main.async {
        NSApp.setActivationPolicy(.accessory)
      }

      Task {
        await Notifications.shared.requestAccess()
      }
    }

    func probePeripheralManager(didDiscover peripheral: CBPeripheral) {
      let peripheralId = peripheral.identifier.uuidString
      // Automatically connect to known probes
      if peripheral.state == .disconnected {
        // TODO: Concurrency
        Task {
          let modelContext = ModelContext(self.modelContainer)

          let descriptor = FetchDescriptor<Probe>(
            predicate: #Predicate { $0.id == peripheralId })
          let count = try modelContext.fetchCount(descriptor)

          if count > 0 {
            logger.debug(
              "Connecting to peripheral: \(peripheralId, privacy: .public)")
            try await self.probePeripheralManager.connect(
              peripheral: peripheral)
            logger.debug(
              "Connected to peripheral: \(peripheralId, privacy: .public)")
          }
        }
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

  class AppDelegate: NSObject, UIApplicationDelegate, ProbePeripheralDelegate,
    UNUserNotificationCenterDelegate
  {
    public let modelContainer: ModelContainer
    public var probePeripheralManager: ProbePeripheralManager!
    private var alerter: TemperatureAlerter!

    var activity: Activity<ProbeActivityAttributes>?

    override init() {
      self.modelContainer = try! ModelContainer.initDefault()
      super.init()
      self.probePeripheralManager = ProbePeripheralManager(
        delegate: self, queue: DispatchQueue.main)
      self.alerter = TemperatureAlerter(
        probePeripheralManager: probePeripheralManager,
        modelContainer: modelContainer)
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

      UNUserNotificationCenter.current().delegate = self
      Task {
        await Notifications.shared.requestAccess()
      }

      return true
    }

    func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping (
        UNNotificationPresentationOptions
      ) -> Void
    ) {
      // Update the app interface directly.

      // Show a banner
      completionHandler(.banner)

    }

    func probePeripheralManager(didDiscover peripheral: CBPeripheral) {
      // Automatically connect to known probes
      if peripheral.state == .disconnected {
        // TODO: Concurrency
        Task {
          let modelContext = ModelContext(self.modelContainer)

          let peripheralId = peripheral.identifier.uuidString
          let descriptor = FetchDescriptor<Probe>(
            predicate: #Predicate { $0.id == peripheralId })
          let count = try modelContext.fetchCount(descriptor)

          if count > 0 {
            logger.debug(
              "Connecting to peripheral: \(peripheral.identifier, privacy: .public)"
            )
            let probe = try await self.probePeripheralManager.connect(
              peripheral: peripheral)
            logger.debug(
              "Connected to peripheral: \(probe.id, privacy: .public)")
          }
        }
      }
    }
  }
#endif
