import SwiftUI
import BBQProbeE

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
          // TODO: Name text field
          // TODO: Connect or disconnect, depending on state
          Button("Connect", role: .destructive) {

          }
          // TODO: Remove from model data. Nice to keep for history etc.?
          // Feature creep: Store "sessions" i.e. a continous use, see data,
          // name courses
          Button("Forget", role: .destructive) {

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
