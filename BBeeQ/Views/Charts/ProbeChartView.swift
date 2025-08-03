//
//  GraphView.swift
//  BBeeQ
//
//  Created by Alex Gustafsson on 2025-08-02.
//

import BBQProbeE
import SwiftUI

struct ProbeChartView: View {
  @State var probe: Probe

  @Environment(\.probePeripheralManager) var probePeripheralManager:
    ProbePeripheralManager?
  @Environment(\.historyManager) var historyManager: HistoryManager?

  private var peripheral: ProbePeripheral? {
    return probePeripheralManager?
      .connections[UUID(uuidString: probe.id)!]
  }

  private var data: [TemperatureOverTime]? {
    return historyManager?
      .probeTemperature[UUID(uuidString: probe.id)!]
  }

  var message1: AttributedString {
    var result = AttributedString("\(peripheral?.probeTemperature ?? 0)°C")
    result.font = .title
    result.foregroundColor = peripheral == nil ? .gray : .red
    return result
  }

  var message3: AttributedString {
    var result = AttributedString("\(probe.temperatureTarget)°C")
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
      Label("\(probe.name) temperature", systemImage: "thermometer.variable")
        .foregroundStyle(peripheral == nil ? .gray : .red)
      Divider()
      HStack {
        VStack(alignment: .leading) {
          HStack(alignment: .center) {
            Circle().fill(peripheral == nil ? .gray : .red)
              .frame(width: 8, height: 8)
            Text("Current").foregroundStyle(peripheral == nil ? .gray : .red)
          }
          Text(message1)
        }
        .padding()
        VStack(alignment: .leading) {
          HStack(alignment: .center) {
            Circle().fill(.gray).frame(width: 8, height: 8)
            Text("Target").foregroundStyle(.gray)
          }
          Text(message3 + message4)
        }
        .padding()
      }
      ProbeChart(
        target: Float(probe.temperatureTarget), connected: peripheral != nil,
        data: data,
      )
    }
    .padding()
    .background(.white)
    .cornerRadius(15)
  }
}

#Preview {
  let probe = Probe(
    id: "1", name: "Probe 1", temperatureTarget: 70, grillTemperatureTarget: 300
  )

  ScrollView {
    ProbeChartView(probe: probe)
  }
}
