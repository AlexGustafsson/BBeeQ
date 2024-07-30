import BBQProbeE
import CoreBluetooth
import SwiftData
import SwiftUI

struct ProbeView: View {
  @State var probe: Probe
  @State var peripheral: ProbePeripheral?

  @State private var presentSheet = false
  @Environment(\.dismiss) var dismiss

  @Query private var probes: [Probe]

  var body: some View {
    HStack {
      VStack {
        HStack {
          Text(probe.name)
          Spacer()
          if peripheral?.state != .connected {
            Image(systemName: "wifi.slash").foregroundStyle(.orange)
          }
          Label {
            Text(
              "\(Int(peripheral?.probeTemperature?.rounded() ?? 0))°C/\(Int(probe.temperatureTarget.rounded()))°C"
            )
          } icon: {
            Image(systemName: "thermometer.medium").foregroundStyle(.red)
          }
          Label {
            Text(
              "\(Int(peripheral?.grillTemperature?.rounded() ?? 0))°C/\(Int(probe.grillTemperatureTarget.rounded()))°C"
            )
          } icon: {
            Image(systemName: "flame").foregroundStyle(.red)
          }
        }
        HStack {
          Image(systemName: "thermometer.medium").foregroundStyle(.red)
          ThermometerSlider(
            current: peripheral?.probeTemperature ?? 0,
            target: $probe.temperatureTarget, minValue: 0, maxValue: 100)
        }
        HStack {
          Image(systemName: "flame").foregroundStyle(.red)
          ThermometerSlider(
            current: peripheral?.grillTemperature ?? 0,
            target: $probe.grillTemperatureTarget, minValue: 0, maxValue: 300)
        }
      }
      Button {
        presentSheet.toggle()
      } label: {
        Image(systemName: "info.circle").resizable().foregroundStyle(.secondary)
          .frame(width: 16, height: 16)
      }
      .buttonStyle(PlainButtonStyle())
      .sheet(isPresented: $presentSheet) {
        // Do nothing
      } content: {
        VStack {
          Form {
            Section("Settings") {
              Slider(
                value: $probe.temperatureTarget, in: 0...100,
                minimumValueLabel: Text("0°C"),
                maximumValueLabel: Text("100°C")
              ) {
                Text("Target temperature")
              }
              Slider(
                value: $probe.grillTemperatureTarget, in: 0...300,
                minimumValueLabel: Text("0°C"),
                maximumValueLabel: Text("300°C")
              ) {
                Text("Target grill temperature")
              }
              TextField("Name", text: $probe.name)
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
              // TODO: Revert changes
              // TODO: Don't modify in-place, keep "newX" variables
              dismiss()
              presentSheet = false
            }
            Button("Done") {
              // TODO: Apply changes
              // TODO: Doesn't work
              dismiss()
              presentSheet = false
            }
            .keyboardShortcut(.defaultAction)
          }
          .padding(20)
        }
      }
    }.padding()
      .background(.white)
      .cornerRadius(15)
  }
}

struct ProbesView: View {
  @Query(sort: \Probe.id) var probes: [Probe]
  @Environment(\.probePeripheralManager) var probePeripheralManager:
    ProbePeripheralManager?

  @State var presentAddProbeSheet: Bool = false

  @State private var discoveredSelection = Set<UUID>()

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      List {
        // TODO: Draggable to move within list
        ForEach(probes) { probe in
          ProbeView(
            probe: probe,
            peripheral: probePeripheralManager?
              .connections[UUID(uuidString: probe.id)!])
        }

        if probes.count == 0 {
          Text("No probes. Probes are automatically added when they are found.")
            .frame(
              maxWidth: .infinity, alignment: .center
            )
            .padding(10).font(.callout).foregroundStyle(.secondary)
            .frame(
              width: .infinity)
        }
      }
      .scrollContentBackground(.hidden)
      .background(.clear)

      // FAB to add
      Button {
        presentAddProbeSheet = true
      } label: {
        Image(systemName: "thermometer.medium")
          .font(.title.weight(.semibold))
          .padding()
          .background(Color.pink)
          .foregroundColor(.white)
          .clipShape(Circle())
          .shadow(radius: 4, x: 0, y: 4)
      }
      .buttonStyle(PlainButtonStyle())
      .overlay {
        let newProbes = Array(probePeripheralManager!.discovered.values).filter { peripheral in !probes.contains(where: { probe in peripheral.identifier.uuidString == probe.id })}
        CountBadge(value: newProbes.count)
          .offset(x: 20, y: -20)
      }
      .padding()
      .sheet(isPresented: $presentAddProbeSheet) {
        // Do nothing
      } content: {
        AddProbesView().frame(width: 520)
      }
    }
  }
}
