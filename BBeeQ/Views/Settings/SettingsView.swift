import SwiftData
import SwiftUI
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Data")

struct SettingsView: View {
  @State private var presentSheet = false

  @Environment(\.modelContext) var modelContext
  @Environment(\.probePeripheralManager) var probePeripheralManager

  @Query(sort: \Probe.id) var probes: [Probe]

  var body: some View {
    VStack {
      Form {
        Section("Probes") {
          ForEach(probes) { probe in
            HStack {
              Text(
                probe.name
              )
              Spacer()
              Button {
                presentSheet.toggle()
              } label: {
                Image(systemName: "info.circle").resizable()
                  .foregroundStyle(.secondary)
                  .frame(width: 16, height: 16)
              }
              .buttonStyle(PlainButtonStyle())
              .sheet(isPresented: $presentSheet) {
                // Do nothing
              } content: {
                ProbeSettingsView(probe: probe, peripheral: nil)
              }
            }
          }

          if probes.count == 0 {
            Text(
              "No probes. Probes are automatically added when they are found."
            )
            .frame(
              maxWidth: .infinity, alignment: .center
            )
            .padding(10).font(.callout).foregroundStyle(.secondary)
          }
        }

        Button("Forget all probes", role: .destructive) {
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
      .formStyle(.grouped)
      #if os(macOS)
        .padding(5)
      #endif
    }
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Probe.self, configurations: config)

  let probe = Probe(
    id: "1", name: "Probe 1", temperatureTarget: 70, grillTemperatureTarget: 300
  )
  container.mainContext.insert(probe)

  return SettingsView()
    .modelContainer(container)
}
