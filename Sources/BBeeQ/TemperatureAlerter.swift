import BBQProbeE
import Combine
import Foundation
import SwiftData
import UserNotifications
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Alerter")

private enum AlertState: Equatable {
  case idle
  case triggered(Double, Double)
}

private struct Thermometer: Identifiable, Hashable, Equatable {
  public var id: UUID
  public var probeId: UUID
  public var label: String
  public var currentKey: KeyPath<ProbePeripheral, Double?>
  public var targetKey: KeyPath<Probe, Double>
  public var alertState: AlertState

  func hash(into hasher: inout Hasher) {
    hasher.combine(self.id)
  }

  static func == (lhs: Thermometer, rhs: Thermometer) -> Bool {
    return lhs.id == rhs.id
  }
}

actor TemperatureAlerter {
  private let probePeripheralManager: ProbePeripheralManager
  private let modelContainer: ModelContainer
  private var timer: (any Cancellable)!

  private var thermometers: Set<Thermometer> = []

  init(
    probePeripheralManager: ProbePeripheralManager,
    modelContainer: ModelContainer
  ) {
    self.probePeripheralManager = probePeripheralManager
    self.modelContainer = modelContainer
    self.timer =
      DispatchQueue
      .global(qos: .utility)
      .schedule(
        after: DispatchQueue.SchedulerTimeType(.now()),
        interval: .seconds(1),
        tolerance: .seconds(5)
      ) { [weak self] in
        guard let self else { return }
        Task { await self.checkAlerts() }  // Trampoline back into the actor context.
      }
  }

  private func triggerAlert(
    temperature: Double, thermometerLabel: String, probeName: String
  ) async {
    let content = UNMutableNotificationContent()
    content.title = "Target \(thermometerLabel) temperature reached"
    content.body = "\(probeName) is at (\(temperature)°C)"

    await Notifications.shared.addImmediate(
      identifier: UUID().uuidString, content: content)
  }

  private func checkAlerts() {
    let modelContext = ModelContext(self.modelContainer)

    // Make sure we keep track of all thermometers
    for probePeripheral in self.probePeripheralManager.connections.values {
      self.thermometers.insert(
        Thermometer(
          id: UUID(fromHash: "\(probePeripheral.id.uuidString) - probe"),
          probeId: probePeripheral.id,
          label: "probe", currentKey: \.probeTemperature,
          targetKey: \.temperatureTarget, alertState: .idle)
      )
      self.thermometers.insert(
        Thermometer(
          id: UUID(fromHash: "\(probePeripheral.id.uuidString) - grill"),
          probeId: probePeripheral.id,
          label: "grill", currentKey: \.grillTemperature,
          targetKey: \.grillTemperatureTarget, alertState: .idle)
      )
    }

    // Go through all thermometers
    for var thermometer in self.thermometers {
      guard
        let probePeripheral = self.probePeripheralManager.connections[
          thermometer.probeId]
      else {
        continue
      }

      guard
        let probe =
          (try? modelContext.fetch(probePeripheral.fetchDescriptor()))?.first
      else {
        continue
      }

      guard let temperature = probePeripheral[keyPath: thermometer.currentKey]
      else {
        continue
      }

      let targetTemperature = probe[keyPath: thermometer.targetKey]

      if temperature >= targetTemperature {
        if thermometer.alertState == .idle {
          logger.debug(
            "Triggering alert for \(probe.name, privacy: .public) (\(thermometer.label, privacy: .public))"
          )
          thermometer.alertState = .triggered(temperature, targetTemperature)
          self.thermometers.update(with: thermometer)
          Task {
            await self.triggerAlert(
              temperature: temperature, thermometerLabel: thermometer.label,
              probeName: probe.name)
          }
        }
      } else if case AlertState.triggered(
        let triggeredTemperature, let triggeredTargetTemperature) = thermometer
        .alertState
      {
        let targetUpdated = targetTemperature != triggeredTargetTemperature
        let temperatureDrop = abs(triggeredTemperature - temperature) > 2
        if targetUpdated || temperatureDrop {
          logger.debug(
            "Closing alert for \(probe.name, privacy: .public) (\(thermometer.label, privacy: .public))"
          )
          thermometer.alertState = .idle
          self.thermometers.update(with: thermometer)
        }
      }
    }
  }
}
