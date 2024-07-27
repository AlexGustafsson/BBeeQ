import CoreBluetooth
import os
import BBQProbeE
import Combine
import SwiftUI

extension EnvironmentValues {
  var probePeripheralManager: ProbePeripheralManager? {
    get { self[ProbePeripheralManagerKey.self] }
    set { self[ProbePeripheralManagerKey.self] = newValue }
  }
}

private struct ProbePeripheralManagerKey: EnvironmentKey {
  static let defaultValue: ProbePeripheralManager? = nil
}

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Main")

struct MenuBarFeedItem: View {
  @Environment(\.probePeripheralManager) var probePeripheralManager: ProbePeripheralManager?

  @State var probe: ProbePeripheral?

  var body: some View {
VStack {
          ForEach(probePeripheralManager!.discovered.keys.sorted(), id: \.uuidString) { uuid in
            Button(uuid.uuidString) {
              Task {
                guard let peripheral = probePeripheralManager?.discovered[uuid] else {
                  return
                }

                do {
                  try await probePeripheralManager!.connect(peripheral: peripheral)
                } catch {
                  print("error: \(error)")
                }
              }
            }
          }

          ForEach(probePeripheralManager!.connections.keys.sorted(), id: \.uuidString) {uuid in
            if let probe = probePeripheralManager?.connections[uuid] {
              Text("Manufacturer: \(probe.manufacturerName)")
              Text("Model: \(probe.modelNumber)")
              Text("Serial: \(probe.serialNumber)")
              Text("Firmware: \(probe.firmwareRevision)")

              Text("Device name: \(probe.deviceName)")
              Text("Grill temperature: \(probe.grillTemperature)")
              Text("Probe temperature: \(probe.probeTemperature)")
            }
          }
        }
        .padding()
  }
}

@main struct BBeeQ: App {
  @State var probePeripheralManager = ProbePeripheralManager(queue: nil)

  // TODO: May be run several times, don't use it to start fetching feeds
  // TODO: Start task runner to load favicons on start. Then run on items and
  // feeds once they are added.

  var body: some Scene {
    WindowGroup {
      MenuBarFeedItem().environment(\.probePeripheralManager, probePeripheralManager)
    }
  }
}
