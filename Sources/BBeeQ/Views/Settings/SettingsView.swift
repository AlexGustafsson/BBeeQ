import SwiftUI
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Data")

struct SettingsView: View {
  @State private var autoConnect = true

  @Environment(\.modelContext) var modelContext
  @Environment(\.probePeripheralManager) var probePeripheralManager

  var body: some View {
    VStack {
      Form {
        Section("General") {
          // TODO: Persist
          Toggle("Auto connect", isOn: $autoConnect)
        }
        Section("Advanced") {
          Button("Forget all probes") {
            logger.debug("Forgetting all probes")
            if let probePeripheralManager = probePeripheralManager {
              for connection in probePeripheralManager.connections.values {
                logger.debug("Disconnecting \(connection.id)")
                probePeripheralManager.disconnect(peripheral: connection)
              }
            }

            do {
              try modelContext.delete(model: Probe.self)
              try modelContext.save()
            } catch {
              logger.error(
                "Failed to delete probes: \(error, privacy: .public)")
            }
          }
        }
      }
      .formStyle(.grouped)
      #if os(macOS)
        .padding(5)
      #endif
    }
  }
}
