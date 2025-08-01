import CoreBluetooth
import Observation
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "ProbePeripheral")

@Observable
public class ProbePeripheral: NSObject, Identifiable, CBPeripheralDelegate {
  public var manufacturerName: String?
  public var modelNumber: String?
  public var serialNumber: String?
  public var firmwareRevision: String?

  public var deviceName: String?
  public var grillTemperature: Double?
  public var probeTemperature: Double?
  public var batteryLow: Bool?

  // Basically reflect peripheral.state, but keep it observable
  public var state: CBPeripheralState

  internal let peripheral: CBPeripheral

  internal init(peripheral: CBPeripheral) {
    self.peripheral = peripheral
    self.state = peripheral.state
    super.init()
    // NOTE: Changing delegate of the peripheral doesn't seem to work, simply
    // relay all calls
    // peripheral.delegate = self

    self.refresh()
  }

  internal func refresh() {
    logger.info("Subscribing to bluetooth updates from peripheral")
    guard
      let probeService = peripheral.services?
        .first(where: { $0.uuid.uuidString == BBQProbeEServiceUUID })
    else {
      logger.error(
        "Failed to subscribe to service updates from peripheral")
      return
    }

    guard
      let deviceInformationService = peripheral.services?
        .first(where: { $0.uuid.uuidString == DeviceInformationServiceUUID })
    else {
      logger.error(
        "Failed to subscribe to device information updates from peripheral")
      return
    }

    // Subscribe to updates for all characteristics that support it
    if let characteristics = probeService.characteristics {
      for characteristic in characteristics {
        if characteristic.properties.contains(.read) {
          logger.debug(
            "Reading characteristic: \(characteristic.uuid, privacy: .public)")
          peripheral.readValue(for: characteristic)
        }
        if characteristic.properties.contains(.notify) {
          logger.debug(
            "Subscribing to characteristic: \(characteristic.uuid, privacy: .public)"
          )
          peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }

    if let characteristics = deviceInformationService.characteristics {
      for characteristic in characteristics {
        if characteristic.properties.contains(.read) {
          logger.debug(
            "Reading characteristic: \(characteristic.uuid, privacy: .public)")
          peripheral.readValue(for: characteristic)
        }
        if characteristic.properties.contains(.notify) {
          logger.debug(
            "Subscribing to characteristic: \(characteristic.uuid, privacy: .public)"
          )
          peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }
  }

  public var id: UUID {
    return self.peripheral.identifier
  }

  public func peripheral(
    _: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
    // TODO: Error handling. For now, let's assume subscriptions work
    if error == nil {
      logger.error(
        "Subscribed to characteristic: \(self.peripheral.identifier, privacy: .public)"
      )

    } else {
      logger.info(
        "Failed to subscribe to characteristic: \(self.peripheral.identifier, privacy: .public) due to \(error, privacy: .public)"
      )
    }
  }

  public func peripheral(
    _: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
    switch characteristic.uuid.uuidString {
    case DeviceInformationManufacturerNameCharacteristicUUID:
      self.manufacturerName = characteristic.value?.ascii
    case DeviceInformationFirmwareRevisionCharacteristicUUID:
      self.firmwareRevision = characteristic.value?.ascii
    case DeviceInformationModelNumberCharacteristicUUID:
      self.modelNumber = characteristic.value?.ascii
    case DeviceInformationSerialNumberCharacteristicUUID:
      self.serialNumber = characteristic.value?.ascii
    case BBQProbeETemperatureEventsCharacteristicUUID:
      self.probeTemperature = convertReadingToDegrees(
        value: characteristic.value!.uint16le(at: 2))
      self.grillTemperature = convertReadingToDegrees(
        value: characteristic.value!.uint16le(at: 4))
    case BBQProbeEDeviceNameCharacteristicUUID:
      self.deviceName = characteristic.value?.ascii
    case BBQProbeEStatusEventsCharacteristicUUID:
      if let value = characteristic.value {
        switch value[1] {
        case 0:
          self.batteryLow = false
        case 1:
          self.batteryLow = true
        default:
          // Unknown case - should only be 0/1
          self.batteryLow = nil
        }
      }
    default:
      // Do nothing
      break
    }
  }

  public func peripheral(didConnect peripheral: CBPeripheral) {
    self.state = peripheral.state
  }

  public func peripheral(
    didDisconnect peripheral: CBPeripheral, error: (any Error)?
  ) {
    logger.info(
      "Peripheral disconnected: \(peripheral.identifier, privacy: .public)")
    self.state = peripheral.state
  }
}

func convertReadingToDegrees(value: UInt16) -> Double {
  // TODO: The official app caps the readings at [0, 300]. Perhaps experiment
  // what range the thermometer actually has
  return max(min(Double(value) / 10 - 40, 300), 0)
}
