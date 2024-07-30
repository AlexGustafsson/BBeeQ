import SwiftUI
import SwiftData

struct ProbeView: View {
  @State var probe: Probe

  @State private var presentSheet = false
  @Environment(\.dismiss) var dismiss

  var body: some View {
    HStack {
      VStack {
        HStack{
          Text("Probe \(probe.id)")
          Spacer()
          Label("\(Int(probe.temperature.rounded()))°C/\(Int(probe.temperatureTarget.rounded()))°C", systemImage: "thermometer.medium")
          Label("\(Int(probe.grillTemperature.rounded()))°C/\(Int(probe.grillTemperatureTarget.rounded()))°C", systemImage: "flame")
        }
        HStack {
          Image(systemName: "thermometer.medium")
          ThermometerSlider(current: $probe.temperature, target: $probe.temperatureTarget, minValue: 0, maxValue: 100)
        }
        HStack {
          Image(systemName: "flame")
          ThermometerSlider(current: $probe.grillTemperature, target: $probe.grillTemperatureTarget, minValue: 0, maxValue: 300)
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
          // Do noting
        } content: {
        VStack {
          Form {
            Section("Settings") {
                Slider(value: $probe.temperatureTarget, in: 0...100, minimumValueLabel: Text("0°C"),
              maximumValueLabel: Text("100°C"))
                {
                  Text("Target temperature")
                }
                Slider(value: $probe.grillTemperatureTarget, in: 0...300, minimumValueLabel: Text("0°C"),
              maximumValueLabel: Text("300°C"))
                {
                  Text("Target grill temperature")
                }
            }
            Section("Advanced") {
              // TODO: Connect or disconnect, depending on state
              Button("Connect", role: .destructive) {

              }
              // TODO: Remove from model data. Nice to keep for history etc.?
              // Feature creep: Store "sessions" i.e. a continous use, see data,
              // name courses
              Button("Forget", role: .destructive) {

              }
            }
          }.padding(5).formStyle(.grouped)

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
          } .padding(20)
        }
      }
    }.padding()
      .background(.white)
      .cornerRadius(15)
  }
}

struct ProbesView: View {
  @Query(sort: \Probe.id) var probes: [Probe]

  var body: some View {
     List {
      // TODO: Draggable to move within list
      ForEach(probes) { probe in
        ProbeView(probe: probe)
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
    }.scrollContentBackground(.hidden)
      .background(.clear)
  }
}
