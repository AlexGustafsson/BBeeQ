import BBQProbeE
import CoreBluetooth
import SwiftData
import SwiftUI

struct ProbeView: View {
  @State var probe: Probe
  @State var peripheral: ProbePeripheral?

  @State private var presentSheet = false

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
        ProbeSettingsView(probe: probe, peripheral: peripheral)
      }
    }.padding()
      .background(.white)
      .cornerRadius(15)
  }
}
