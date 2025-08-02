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
  typealias MultiplatformApplicationDelegate = NSApplicationDelegate
#elseif os(iOS)
  typealias MultiplatformApplicationDelegate = UIApplicationDelegate
#endif

class AppDelegate: NSObject, MultiplatformApplicationDelegate,
  ProbePeripheralDelegate
{
  public var probePeripheralManager: ProbePeripheralManager!
  public var historyManager: HistoryManager!

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

  override init() {
    super.init()
    self.probePeripheralManager = ProbePeripheralManager(
      delegate: self, queue: DispatchQueue.main)
    self.historyManager = HistoryManager(
      probeManager: self.probePeripheralManager)
    self.historyManager.start()
  }

  #if os(macOS)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
      logger.info("Started RSSBar")
    }
  #endif

  #if os(iOS)
    func application(
      _: UIApplication,
      didFinishLaunchingWithOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      logger.info("Started RSSBar")
      return true
    }
  #endif

  func probePeripheralManager(didDiscover peripheral: CBPeripheral) {
    let peripheralId = peripheral.identifier.uuidString
    // Automatically connect to known probes
    if peripheral.state == .disconnected {
      // TODO: Concurrency
      Task {
        let modelContext = ModelContext(self.sharedModelContainer)

        let descriptor = FetchDescriptor<Probe>(
          predicate: #Predicate { $0.id == peripheralId })
        let count = try modelContext.fetchCount(descriptor)

        if count > 0 {
          logger.debug(
            "Auto connecting to peripheral: \(peripheralId, privacy: .public)"
          )
          _ = try await self.probePeripheralManager.connect(
            peripheral: peripheral)
          logger.debug(
            "Auto connected to peripheral: \(peripheralId, privacy: .public)")
        }
      }
    }
  }
}
