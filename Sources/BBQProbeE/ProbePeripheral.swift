import os
import Observation
import CoreBluetooth

@Observable public class ProbePeripheral: NSObject, Identifiable, CBPeripheralDelegate {
  private let peripheral: CBPeripheral

  public var manufacturerName: String?
  public var modelNumber: String?
  public var serialNumber: String?
  public var firmwareRevision: String?

  public var deviceName: String?
  public var grillTemperature: Float?
  public var probeTemperature: Float?

  internal init(peripheral: CBPeripheral)  {
    self.peripheral = peripheral
    super.init()
    // NOTE: Changing delegate of the peripheral doesn't seem to work, simply
    // relay all calls
    // peripheral.delegate = self

    print("subscribing")
    guard let probeService = peripheral.services?.first(where: {$0.uuid.uuidString == BBQProbeEServiceUUID}) else {
    print("failed to subscribe")
      return
    }

    guard let deviceInformationService = peripheral.services?.first(where: {$0.uuid.uuidString == DeviceInformationServiceUUID}) else {
    print("failed to subscribe")
      return
    }

    // Subscribe to updates for all characteristics that support it
    if let characteristics = probeService.characteristics {
      for characteristic in characteristics {
        if characteristic.properties.contains(.read) {
          print("reading \(characteristic.uuid)")
         peripheral.readValue(for: characteristic)
        }
        if characteristic.properties.contains(.notify) {
          print("subscribing \(characteristic.uuid)")
         peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }

    if let characteristics = deviceInformationService.characteristics {
      for characteristic in characteristics {
        if characteristic.properties.contains(.read) {
          print("reading \(characteristic.uuid)")
         peripheral.readValue(for: characteristic)
        }
        if characteristic.properties.contains(.notify) {
          print("subscribing \(characteristic.uuid)")
         peripheral.setNotifyValue(true, for: characteristic)
        }
      }
    }
  }

  public var id: UUID {
    return self.peripheral.identifier
  }

  public func peripheral(_: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
     // TODO: Error handling. For now, let's assume subscriptions work
     print("notify \(characteristic.uuid) - \(error)")
  }

  public func peripheral(_: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
    print("\(characteristic.uuid): \(characteristic.value?.hex)")

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
        self.probeTemperature = convertReadingToDegrees(value: characteristic.value!.uint16le(at: 2))
        self.grillTemperature = convertReadingToDegrees(value: characteristic.value!.uint16le(at: 4))
      case BBQProbeEDeviceNameCharacteristicUUID:
        self.deviceName = characteristic.value?.ascii
      default:
        // Do nothing
        break
    }
  }
}

func convertReadingToDegrees(value: UInt16) -> Float {
  // TODO: The official app caps the readings at [0, 300]. Perhaps experiment
  // what range the thermometer actually has
  return max(min(Float(value) / 10 - 40, 300), 0)
}
