import BBQProbeE
import CoreBluetooth
import SwiftData
import SwiftUI
import UserNotifications

struct AddProbesView: View {
  @State private var selection: Set<UUID> = Set()
  @State private var adding: Bool = false

  @Environment(\.dismiss) var dismiss
  @Environment(\.modelContext) var modelContext

  @Environment(\.probePeripheralManager) var probePeripheralManager:
    ProbePeripheralManager?

  @Query private var probes: [Probe]

  private func addSelection() {
    self.adding = true
    Task {
      defer { self.adding = false }
      guard let manager = self.probePeripheralManager else {
        return
      }

      do {
        try await withThrowingTaskGroup(of: ProbePeripheral.self) {
          taskGroup in
          for uuid in self.selection {
            guard let peripheral = manager.discovered[uuid] else {
              continue
            }

            taskGroup.addTask {
              let probe = try await self.probePeripheralManager!
                .connect(peripheral: peripheral)

              let context = await ModelContext(modelContext.container)
              // TODO: Name is always empty as we haven't gotten the
              // device name characteristic yet
              context.insert(
                Probe(
                  id: probe.id.uuidString,
                  name: probe.deviceName ?? "Probe \(probes.count + 1)",
                  temperatureTarget: 65, grillTemperatureTarget: 300))
              try context.save()

              // TODO: Swift breaks if we don't state of: ProbePeripheral
              // and return something
              return probe
            }
          }
        }

        //let content = UNMutableNotificationContent()
        //content.title = "Title"
        //content.body = "Body"
        //content.sound = UNNotificationSound.default
        //content.interruptionLevel = .timeSensitive
        //await Notifications.shared.addImmediate(
        // identifier: UUID().uuidString, content: content)
      } catch {
        print("failed")
        // TODO: Handle errors
        return
      }

      dismiss()
    }
  }

  var body: some View {
    VStack {
      Form {
        Section {
          let allProbes =
            if let probePeripheralManager = self.probePeripheralManager {
              Array(probePeripheralManager.discovered.values)
            } else {
              [CBPeripheral]()
            }
          let newProbes = allProbes.filter { peripheral in
            !probes.contains(where: { probe in
              peripheral.identifier.uuidString == probe.id
            })
          }
          Select(data: newProbes, id: \.identifier, selection: $selection) {
            peripheral, selected in
            HStack {
              Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(.blue)
              Text(peripheral.identifier.uuidString)
            }
          }
        } header: {
          HStack {
            Text(adding ? "Connecting probes" : "Discovering probes")
            ProgressView().scaleEffect(0.5)
          }
        }
      }
      .formStyle(.grouped)
      #if os(macOS)
        .padding(5)
      #endif

      // Footer
      HStack {
        Spacer()
        Button("Cancel") {
          dismiss()
        }
        .disabled(adding)
        Button(selection.count == 0 ? "Add" : "Add \(selection.count)") {
          self.addSelection()
        }
        .disabled(selection.count == 0 || adding)
        .keyboardShortcut(.defaultAction)
      }
      #if (os(macOS))
        .padding(20)
      #endif
    }
    #if (os(iOS))
      .safeAreaPadding()
    #endif
  }
}

#Preview {
  AddProbesView()
    .modelContainer(for: Probe.self, inMemory: true)
}
