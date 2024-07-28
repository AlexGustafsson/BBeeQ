import SwiftUI
import Charts

struct ThermometerSlider: View {
  @Binding var current: Double
  @Binding var target: Double

  @State var mutable = true

  @State var minValue = Int(0)
  @State var maxValue = Int(300)

  @State private var held = false

  private let trackHeight: CGFloat = 8
  private let thumbRadius: CGFloat = 10

  var body: some View {
        GeometryReader { geometry in
            //--Container ZStack
            ZStack(alignment: .leading){
                //--Track
                RoundedRectangle(cornerRadius: 4)
                    .fill(.red.opacity(0.5))
                    .frame(width: geometry.size.width, height: trackHeight)
                    .onTapGesture { location in
                      if mutable {
                        withAnimation {
                          target = Double((location.x / geometry.size.width) * CGFloat(maxValue - minValue)) + Double(minValue)
                        }
                      }
                    }

                //--Tinted track
                let currentWidth = geometry.size.width * CGFloat(current)/CGFloat(maxValue - minValue)
                RoundedRectangle(cornerRadius: 4)
                    .fill(.red)
                    .frame(width: currentWidth, height: trackHeight)
                    .allowsHitTesting(false)

                //--Thumb
                Circle()
                    .fill(.white)
                    .fill(.gray.opacity(held ? 0.1 : 0.0))
                    .frame(width: thumbRadius * 2)
                    .shadow(radius: 1)

                    .offset(x: CGFloat(CGFloat(target) / CGFloat(maxValue) * geometry.size.width - thumbRadius))

                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                              if mutable {
                                  held = true
                                  updateValue(with: gesture, in: geometry)
                              }
                            }
                            .onEnded { _ in
                              held = false
                            }
                    )

            }

        }
        .frame(height: 2 * thumbRadius)
        .padding([.leading, .trailing], thumbRadius)
  }

  private func updateValue(with gesture: DragGesture.Value, in geometry: GeometryProxy) {
        let dragPortion = gesture.location.x / geometry.size.width
        let newValue = Int(dragPortion * CGFloat(maxValue - minValue) + CGFloat(minValue))
        target = Double(min(max(newValue, minValue), maxValue))
    }
}

struct Probe: Identifiable {
  var id: Int
  var temperature: Double
  var temperatureTarget: Double
  var grillTemperature: Double
  var grillTemperatureTarget: Double
  // TODO: Store state as enum so that all parts of the UI always handle it
  // correctly, when e.g. current is not available
  var mode: ProbeMode = .temperature
}

enum ProbeMode: String, CaseIterable, Identifiable {
  // TODO: Don't use the hardware's modes? No need to support timers etc?
  // Just save the info and let the app deal with it? Always put it in whatever
  // mode gives us the most data (temp mode - probe and grill?)
  case temperature, timer
  var id: Self { self }
}

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
              Picker("Mode", selection: $probe.mode) {
                Text("Temperature").tag(ProbeMode.temperature)
                Text("Timer").tag(ProbeMode.timer)
              }

              switch probe.mode {
                case .temperature:
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
                case .timer:
                  Text("TODO")
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

struct ThermometerView: View {
  private var probes: [Probe] = [Probe(id: 1, temperature: 20, temperatureTarget: 71, grillTemperature: 100, grillTemperatureTarget: 200), Probe(id: 2, temperature: 20, temperatureTarget: 71, grillTemperature: 100, grillTemperatureTarget: 20)]

  var body: some View {
     List {
      // TODO: Draggable to move within list
      ForEach(probes) { probe in
        ProbeView(probe: probe)
      }

      // TODO: Empty placeholder
    }.scrollContentBackground(.hidden)
      .background(.clear)
  }
}

struct TemperatureOverTime {
    var date: Date
    var temperature: Float
}

struct PulsatingCircle: View {
    @State var animate = false
    var body: some View {
        VStack {
            ZStack {
                Circle().fill(.red).strokeBorder(.white, lineWidth: 2).frame(width: 12, height: 12)
                Circle().fill(.red.opacity(0.25)).frame(width: 40, height: 40).scaleEffect(self.animate ? 1 : 0)
                Circle().fill(.red.opacity(0.35)).frame(width: 30, height: 30).scaleEffect(self.animate ? 1 : 0)
                Circle().fill(.red.opacity(0.45)).frame(width: 15, height: 15).scaleEffect(self.animate ? 1 : 0)
            }
            .onAppear { self.animate.toggle() }
            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: animate)
        }
    }
}

struct ExampleChart :View {
    // TODO: auto compaction - second to minute resolution - use average for readings
    let data: [TemperatureOverTime] = [Int](0...20).map {TemperatureOverTime(date: Date.now.advanced(by: -TimeInterval($0 * 60)), temperature: Float.random(in: 20...26))}
    let prediction: [TemperatureOverTime] = [Int](0...20).map {TemperatureOverTime(date: Date.now.advanced(by: TimeInterval($0 * 60)), temperature: Float.random(in: 1...5) + (Float($0)/20) * 50 + 20)}

  var body: some View {
    Chart {
      // Target horizontal line
      RuleMark(y: .value("Target", 70)).lineStyle(StrokeStyle(lineWidth: 1, dash: [3])).foregroundStyle(.red)

      // Data
      ForEach(data, id: \.date) { item in
        LineMark(
            x: .value("Date", item.date),
            y: .value("Temperature", item.temperature),
            series: .value("Probe", "1")
        )
        .foregroundStyle(.red)
      }

      // Prediction
      ForEach(prediction, id: \.date) { item in
        LineMark(
            x: .value("Date", item.date),
            y: .value("Temperature", item.temperature)
        )
        .foregroundStyle(.gray.opacity(0.5))
      }

      // Now point
      PointMark(x: .value("Date", Date.now), y: .value("Temperature", data.last!.temperature)).symbol {
                        PulsatingCircle()
                            .frame(width: 12)
                    }

  }.padding()
  .chartXAxis {
    AxisMarks(values: .automatic(desiredCount: 3)) { value in
      AxisGridLine(centered: true, stroke: StrokeStyle(dash: [1, 2]))
      AxisTick(centered: true, length: 4, stroke: StrokeStyle(lineWidth: 2, lineCap: .round ,lineJoin: .round))
      AxisValueLabel(format: .dateTime.hour().minute(), anchor: .center)
    }
    AxisMarks(values: .stride(by: .minute)) { value in
      AxisTick(centered: true, length: 1, stroke: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin:  .round))
    }
}.chartYAxis {
  AxisMarks { value in
        AxisGridLine()
        AxisValueLabel() {
          Text("\(value.as(Int.self)!)°C")
        }
    }
}

  .chartOverlay { proxy in
    GeometryReader { geometry in
        Rectangle().fill(.clear).contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Convert the gesture location to the coordinate space of the plot area.
                        let origin = geometry[proxy.plotFrame!].origin
                        let location = CGPoint(
                            x: value.location.x - origin.x,
                            y: value.location.y - origin.y
                        )
                        // Get the x (date) and y (price) value from the location.
                        let (date, price) = proxy.value(at: location, as: (Date, Float).self)!
                        print("Location: \(date), \(price)")
                    }
            ).onContinuousHover { phase in
              switch phase {
              case .active(let location):
              // Get the x (date) and y (price) value from the location.
              let (date, price) = proxy.value(at: location, as: (Date, Float).self)!
              print("Location: \(date), \(price)")
              case .ended:
                  break
              }
            }
    }
}
  }
}

struct ChartCard: View {

   var message1: AttributedString {
        var result = AttributedString("23°C")
        result.font = .title
        result.foregroundColor = .red
        return result
    }

   var message3: AttributedString {
        var result = AttributedString("70°C")
        result.font = .title
        result.foregroundColor = .gray
        return result
    }

    var message4: AttributedString {
        var result = AttributedString(" in 25m")
        result.foregroundColor = .gray
        return result
    }


  var body: some View {
    VStack(alignment: .leading) {
         Label("Probe temperature", systemImage: "flame.fill").foregroundStyle(.red)
         Divider()
         HStack {
            VStack(alignment: .leading) {
              HStack(alignment: .center) {
                Circle().fill(.red).frame(width: 8, height: 8)
                Text("Current").foregroundStyle(.red)
              }
              Text(message1)
            }.padding()
            VStack(alignment: .leading) {
              HStack(alignment: .center) {
                Circle().fill(.gray).frame(width: 8, height: 8)
                Text("Target").foregroundStyle(.gray)
              }
              Text(message3 + message4)
            }.padding()
         }
         ExampleChart()
      }
      .padding()
      .background(.white)
      .cornerRadius(15)
  }
}

struct ChartsView: View {
  var body: some View {
    ScrollView {
      ChartCard().padding()
      ChartCard().padding()
      ChartCard().padding()

      // TODO: Probe cards and a single grill card with average and min max area
      // ruler
    }
  }
}

struct SettingsView: View {
  @State private var autoConnect = true

  var body: some View {
    VStack {
          Form {
            Section("General") {
              Toggle("Auto connect", isOn: $autoConnect)
            }
            Section("Advanced") {
              Button("Disconnect all probes")  {

              }
              Button("Forgett all probes") {

              }
            }
          }.padding(5).formStyle(.grouped)
    }
  }
}

struct AppView: View {
  @State private var selectedTab: String = ""

  var body: some View {
    TabView(selection: $selectedTab) {
      ThermometerView()
        .tabItem {
            Label("Thermometer", systemImage: "thermometer.medium")
        }

      ChartsView()
        .tabItem {
            Label("Charts", systemImage: "chart.xyaxis.line")
        }
      SettingsView()
        .tabItem {
            Label("Settings", systemImage: "gearshape")
        }
    }
  }
}
