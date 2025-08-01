import BBQProbeE
import SwiftUI
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "UI/ProbeSettings")

struct ProbeSettingsView: View {
  @State var probe: Probe
  @State var peripheral: ProbePeripheral?

  @State private var newTemperatureTarget: Double
  @State private var newGrillTemperatureTarget: Double
  @State private var newName: String

  init(probe: Probe, peripheral: ProbePeripheral?) {
    self.probe = probe
    self.peripheral = peripheral
    self.newTemperatureTarget = probe.temperatureTarget
    self.newGrillTemperatureTarget = probe.grillTemperatureTarget
    self.newName = probe.name
  }

  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @Environment(\.probePeripheralManager) private var probePeripheralManager

  private func forget() {
    if let peripheral = peripheral {
      probePeripheralManager?.disconnect(peripheral: peripheral)
    }

    do {
      modelContext.delete(probe)
      try modelContext.save()
    } catch {
      logger.error(
        "Failed to delete probe: \(error, privacy: .public)")
    }

    dismiss()
  }

  var body: some View {
    VStack {
      Form {
        Section("Settings") {
          Slider(
            value: $newTemperatureTarget, in: 0...100,
            minimumValueLabel: Text("0°C"),
            maximumValueLabel: Text("100°C")
          ) {
            Text("Target temperature")
          }
          Slider(
            value: $newGrillTemperatureTarget, in: 0...300,
            minimumValueLabel: Text("0°C"),
            maximumValueLabel: Text("300°C")
          ) {
            Text("Target grill temperature")
          }
          TextField("Name", text: $newName)
        }
        Section("Data") {
          LabeledContent("Probe temperature") {
            Text(peripheral?.probeTemperature?.formatted(.number) ?? "")
          }
          LabeledContent("Grill temperature") {
            Text(peripheral?.grillTemperature?.formatted(.number) ?? "")
          }
          LabeledContent("Battery low") {
            Text(
              peripheral?.batteryLow == nil
                ? "" : peripheral?.batteryLow == true ? "yes" : "no")
          }
        }
        Section("Advanced") {
          LabeledContent("Device name") {
            Text(peripheral?.deviceName ?? "")
          }
          LabeledContent("ID") { Text(peripheral?.id.uuidString ?? "") }
          LabeledContent("Manufacturer") {
            Text(peripheral?.manufacturerName ?? "")
          }
          LabeledContent("Model number") {
            Text(peripheral?.modelNumber ?? "")
          }
          LabeledContent("Serial number") {
            Text(peripheral?.serialNumber ?? "")
          }
          LabeledContent("Firmware revision") {
            Text(peripheral?.firmwareRevision ?? "")
          }
          // TODO: Remove from model data. Nice to keep for history etc.?
          // Feature creep: Store "sessions" i.e. a continous use, see data,
          // name courses
          Button("Forget", role: .destructive) {
            self.forget()
          }
        }
      }
      .padding(5).formStyle(.grouped)

      // Footer
      HStack {
        Spacer()
        Button("Cancel") {
          dismiss()
        }
        Button("Done") {
          self.probe.temperatureTarget = self.newTemperatureTarget
          self.probe.grillTemperatureTarget = self.newGrillTemperatureTarget
          self.probe.name = self.newName
          try? self.modelContext.save()
          dismiss()
        }
        .keyboardShortcut(.defaultAction)
      }
      .padding(20)
    }
  }
}

#Preview {
  let probe = Probe(
    id: "1", name: "Probe 1", temperatureTarget: 70, grillTemperatureTarget: 300
  )
  ProbeSettingsView(probe: probe, peripheral: nil)
}
