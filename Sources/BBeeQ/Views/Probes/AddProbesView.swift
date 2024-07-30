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

  var body: some View {
    VStack {
      Form {
        Section("Discovered probes") {
          List(
            // TODO: Show only new probes, not existing ones
            Array(probePeripheralManager!.discovered.values), id: \.identifier,
            selection: $selection
          ) { peripheral in
            Text(peripheral.identifier.uuidString)
          }
          // if let discovered = probePeripheralManager?.discovered.values.sorted {$0.identifier.uuidString < $1.identifier.uuidString} {
          //   List(Array(discovered), id: \.identifier, selection: $discoveredSelection) { identifier in
          //     Text(identifier.uuidString)
          //   }
          // }
        }
      }
      .padding(5).formStyle(.grouped)

      // Footer
      HStack {
        Spacer()
        Button("Cancel") {
          // TODO: Revert changes
          // TODO: Don't modify in-place, keep "newX" variables
          dismiss()
        }
        Button(selection.count == 0 ? "Add" : "Add \(selection.count)") {
          self.adding = true
          Task {
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
                    context.insert(Probe(id: probe.id.uuidString, name: probe.deviceName ?? "", temperatureTarget: 65, grillTemperatureTarget: 300))
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
        .disabled(selection.count == 0)
        .keyboardShortcut(.defaultAction)
      }
      .padding(20)
    }
  }
}
