import BBQProbeE
import CoreBluetooth
import SwiftData
import SwiftUI

struct ProbeView: View {
  @State var probe: Probe

  @State private var presentSheet = false

  @Query private var probes: [Probe]

  @Environment(\.probePeripheralManager) var probePeripheralManager

  private var peripheral: ProbePeripheral? {
    return probePeripheralManager?
      .connections[UUID(uuidString: probe.id)!]
  }

  var body: some View {
    VStack(alignment: .leading) {
      // Status bar
      HStack(alignment: .center) {
        Text(probe.name)
        if peripheral?.state != .connected {
          Image(systemName: "wifi.slash").foregroundStyle(.orange).blinking()
        }
        if peripheral?.batteryLow == true {
          Image(systemName: "battery.25percent").foregroundStyle(.orange)
            .blinking()
        }
        Spacer()
        // Details
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
          ProbeSettingsView(probe: probe, peripheral: peripheral)
        }
      }
      Spacer(minLength: 12)

      // Probe
      VStack(alignment: .center) {
        Label {
          Text(
            "\(Int(peripheral?.probeTemperature?.rounded() ?? 0))°C/\(Int(probe.temperatureTarget.rounded()))°C"
          )
        } icon: {
          Image(systemName: "thermometer.variable").foregroundStyle(.red)
        }
        ThermometerSlider(
          current: peripheral?.probeTemperature ?? 0,
          target: $probe.temperatureTarget, minValue: 0, maxValue: 100)
      }

      Divider()

      // Grill
      VStack(alignment: .center) {
        ThermometerSlider(
          current: peripheral?.grillTemperature ?? 0,
          target: $probe.grillTemperatureTarget, minValue: 0, maxValue: 300)
        Label {
          Text(
            "\(Int(peripheral?.grillTemperature?.rounded() ?? 0))°C/\(Int(probe.grillTemperatureTarget.rounded()))°C"
          )
        } icon: {
          Image(systemName: "flame").foregroundStyle(.red)
        }
      }
    }
    .padding()
    .background(.white)
    .cornerRadius(15)
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Probe.self, configurations: config)

  let probe = Probe(
    id: "1", name: "Probe 1", temperatureTarget: 70, grillTemperatureTarget: 300
  )
  container.mainContext.insert(probe)

  return ScrollView {
    ProbeView(probe: probe)
      .modelContainer(container)
  }
}
