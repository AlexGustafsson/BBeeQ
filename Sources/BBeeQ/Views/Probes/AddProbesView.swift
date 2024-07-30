import BBQProbeE
import CoreBluetooth
import SwiftUI
import SwiftData

struct AddProbesView: View {
  @State private var selection: Set<UUID> = Set()
  @State private var adding: Bool = false

  @Environment(\.dismiss) var dismiss
  @Environment(\.modelContext) var modelContext

  @Environment(\.probePeripheralManager) var probePeripheralManager:
    ProbePeripheralManager?

  @Query private var probes: [Probe]

  var body: some View {
    VStack {
      Form {
        Section {
          let newProbes = Array(probePeripheralManager!.discovered.values).filter { peripheral in !probes.contains(where: { probe in peripheral.identifier.uuidString == probe.id })}
          List(
            newProbes, id: \.identifier,
            selection: $selection
          ) { peripheral in
            Text(peripheral.identifier.uuidString)
          }
        } header: {
          HStack {
            Text(adding ? "Connecting probes" : "Discovering probes")
            ProgressView().scaleEffect(0.5)
          }
        }
      }
      .padding(5).formStyle(.grouped)

      // Footer
      HStack {
        Spacer()
        Button("Cancel") {
          dismiss()
        }.disabled(adding)
        Button(selection.count == 0 ? "Add" : "Add \(selection.count)") {
          self.adding = true
          Task {
            defer {self.adding = false}
            guard let manager = self.probePeripheralManager else {
              return
            }

            do {
             try await withThrowingTaskGroup(of: ProbePeripheral.self) {
                taskGroup in
                for id in selection {
                  guard let peripheral = manager.discovered[id] else {
                    continue
                  }

                  taskGroup.addTask {
                    let probe = try await self.probePeripheralManager!
                      .connect(peripheral: peripheral)

                    let context = ModelContext(modelContext.container)
                    // TODO: Name is always empty as we haven't gotten the
                    // device name characteristic yet
                    context.insert(Probe(id: probe.id.uuidString, name: probe.deviceName ?? "Probe \(probes.count + 1)", temperatureTarget: 65, grillTemperatureTarget: 300))
                    try context.save()

                    // TODO: Swift breaks if we don't state of: ProbePeripheral
                    // and return something
                    return probe
                  }
                }
              }
            } catch {
              print("failed")
              // TODO: Handle errors
              return
            }

            dismiss()
          }
        }
        .disabled(selection.count == 0 || adding)
        .keyboardShortcut(.defaultAction)
      }
      .padding(20)
    }
  }
}