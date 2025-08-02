import BBQProbeE
import SwiftData
import SwiftUI

@Observable
class HistoryManager {
  private var probeManager: ProbePeripheralManager
  private var timer: Timer?
  var probeTemperature: [UUID: [TemperatureOverTime]]

  init(probeManager: ProbePeripheralManager) {
    self.probeManager = probeManager
    self.probeTemperature = [:]
  }

  func start() {
    let timer = Timer.scheduledTimer(
      withTimeInterval: 5, repeats: true,
      block: { timer in
        self.run()
      })
    RunLoop.current.add(timer, forMode: .common)
    self.timer = timer
  }

  deinit {
    self.timer?.invalidate()
  }

  private func run() {
    probeManager.connections.values.forEach { probe in
      var data = self.probeTemperature[probe.id] ?? []
      if probe.state == .connected {
        if let probeTemperature = probe.probeTemperature {
          data.append(
            TemperatureOverTime(
              date: Date(), temperature: Float(probeTemperature)))
        }
      }
      self.probeTemperature[probe.id] = data
    }
  }
}
