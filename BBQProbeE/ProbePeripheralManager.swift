import CoreBluetooth
import os

internal let BBQProbeEServiceUUID = "FB00"
internal let BBQProbeEDeviceNameCharacteristicUUID = "FB01"
internal let BBQProbeETemperatureEventsCharacteristicUUID = "FB02"
internal let BBQProbeEWriteCharacteristicUUID = "FB03"
internal let BBQProbeEResponseCharacteristicUUID = "FB04"
internal let BBQProbeEStatusEventsCharacteristicUUID = "FB05"

internal let DeviceInformationServiceUUID = "180A"
internal let DeviceInformationManufacturerNameCharacteristicUUID = "2A29"
internal let DeviceInformationModelNumberCharacteristicUUID = "2A24"
internal let DeviceInformationSerialNumberCharacteristicUUID = "2A25"
internal let DeviceInformationFirmwareRevisionCharacteristicUUID = "2A26"

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "ProbePeripheralManager")

enum Message {
  case discovered(CBPeripheral)
}

public protocol ProbePeripheralDelegate {
  func probePeripheralManager(didDiscover: CBPeripheral)
}

@Observable
public class ProbePeripheralManager: NSObject, CBCentralManagerDelegate,
  CBPeripheralDelegate
{
  private var centralManager: CBCentralManager!
  private var delegate: ProbePeripheralDelegate

  public var discovered: [UUID: CBPeripheral] = [:]
  public var connectionAttempts: [UUID: CheckedContinuation<(), any Error>] =
    [:]
  public var connections: [UUID: ProbePeripheral] = [:]

  // TODO: Equatable, but can't be done due to connectionFailed error
  enum ConnectionError: Error {
    case connectionInProgress
    case alreadyConnected
    case missingRequiredServices
    case connectionFailed((any Error)?)
  }

  public init(delegate: ProbePeripheralDelegate, queue: dispatch_queue_t?) {
    self.delegate = delegate
    super.init()
    self.centralManager = CBCentralManager(delegate: self, queue: queue)
  }

  public func connect(peripheral: CBPeripheral) async throws -> ProbePeripheral
  {
    logger.info(
      "Connecting to peripheral: \(peripheral.identifier, privacy: .public)")
    if self.connectionAttempts[peripheral.identifier] != nil {
      throw ConnectionError.connectionInProgress
    }

    if self.connections[peripheral.identifier] != nil {
      throw ConnectionError.alreadyConnected
    }

    // Wait for the peripheral to be connected and validated
    try await withCheckedThrowingContinuation { continuation in
      self.connectionAttempts[peripheral.identifier] = continuation
      peripheral.delegate = self
      // TODO: reconnect doesn't seem to be working?
      self.centralManager.connect(
        peripheral,
        options: [CBConnectPeripheralOptionEnableAutoReconnect: true])
    }

    let p = ProbePeripheral(peripheral: peripheral)
    self.connections[peripheral.identifier] = p
    self.connectionAttempts[peripheral.identifier] = nil
    return p
  }

  public func disconnect(peripheral: ProbePeripheral) {
    self.centralManager.cancelPeripheralConnection(peripheral.peripheral)
    self.connections[peripheral.id] = nil
    self.connectionAttempts[peripheral.id] = nil
  }

  public func centralManagerDidUpdateState(_ manager: CBCentralManager) {
    // Start scanning
    if manager.state == .poweredOn {
      logger.info("Scanning for peripherals")
      self.centralManager.scanForPeripherals(withServices: [
        CBUUID(string: BBQProbeEServiceUUID)
      ])
    } else {
      logger.warning(
        "Failed to start bluetooth modem: \(manager.state.debugDescription, privacy: .public)"
      )
    }
  }

  public func centralManager(
    _ manager: CBCentralManager, didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any], rssi: NSNumber
  ) {
    if self.discovered[peripheral.identifier] == nil {
      logger.info("Discovered peripheral")
      self.discovered[peripheral.identifier] = peripheral
      self.delegate.probePeripheralManager(didDiscover: peripheral)
    }
  }

  public func centralManager(
    _ manager: CBCentralManager, didConnect peripheral: CBPeripheral
  ) {
    // Discover services for the peripheral, kick starting the connection
    // validation flow
    logger.info("Connected to peripheral, discovering services")
    peripheral.discoverServices([
      CBUUID(string: BBQProbeEServiceUUID),
      CBUUID(string: DeviceInformationServiceUUID),
    ])
  }

  public func centralManager(
    _ manager: CBCentralManager, didFailToConnect peripheral: CBPeripheral,
    error: (any Error)?
  ) {
    logger.error("Failed to connect to peripheral: \(error, privacy: .public)")

    guard let connectionAttempt = self.connectionAttempts[peripheral.identifier]
    else {
      return
    }
    connectionAttempt.resume(throwing: ConnectionError.connectionFailed(error))
    self.connectionAttempts[peripheral.identifier] = nil
  }

  public func centralManager(
    _ manager: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?
  ) {
    if error == nil {
      logger.info(
        "Disconnected from peripheral: \(peripheral.identifier, privacy: .public)"
      )
    } else {
      logger.error(
        "Disconnected from peripheral: \(peripheral.identifier, privacy: .public) due to \(error, privacy: .public)"
      )
    }
    // Received when docking:
    // disconnected Optional(Error Domain=CBErrorDomain Code=6 "The connection has timed out unexpectedly." UserInfo={NSLocalizedDescription=The connection has timed out unexpectedly.})
    // TODO - use and figure out if we need this and the one below, or just one
    // of them
    if let connection = self.connections.removeValue(
      forKey: peripheral.identifier)
    {
      connection.peripheral(didDisconnect: peripheral, error: error)
    }
  }

  public func centralManager(
    _ manager: CBCentralManager,
    didDisconnectPeripheral peripheral: CBPeripheral, timestamp: CFAbsoluteTime,
    isReconnecting: Bool, error: (any Error)?
  ) {
    if error == nil {
      logger.info(
        "Disconnected from peripheral: \(peripheral.identifier, privacy: .public)"
      )
    } else {
      logger.error(
        "Disconnected from peripheral: \(peripheral.identifier, privacy: .public) due to \(error, privacy: .public)"
      )
    }
    if isReconnecting {
      logger.info(
        "Reconnecting to peripheral: \(peripheral.identifier, privacy: .public)"
      )
    }
    // TODO - use and figure out if we need this and the one above, or just one
    // of them
    // TODO: Delete from connections?
  }

  public func peripheral(
    _ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?
  ) {
    logger.info("Discovered services")
    guard let connectionAttempt = self.connectionAttempts[peripheral.identifier]
    else {
      return
    }

    // Failed to connect
    if let error = error {
      connectionAttempt.resume(throwing: error)
      self.connectionAttempts[peripheral.identifier] = nil
      return
    }

    // Validate that the services exist
    guard
      let probeService = peripheral.services?
        .first(where: { $0.uuid.uuidString == BBQProbeEServiceUUID })
    else {
      connectionAttempt.resume(
        throwing: ConnectionError.missingRequiredServices)
      self.connectionAttempts[peripheral.identifier] = nil
      return
    }

    guard
      let deviceInformationService = peripheral.services?
        .first(where: { $0.uuid.uuidString == DeviceInformationServiceUUID })
    else {
      connectionAttempt.resume(
        throwing: ConnectionError.missingRequiredServices)
      self.connectionAttempts[peripheral.identifier] = nil
      return
    }

    // Discover required characteristics
    peripheral.discoverCharacteristics(
      [
        CBUUID(string: BBQProbeEDeviceNameCharacteristicUUID),
        CBUUID(string: BBQProbeETemperatureEventsCharacteristicUUID),
        CBUUID(string: BBQProbeEResponseCharacteristicUUID),
        CBUUID(string: BBQProbeEStatusEventsCharacteristicUUID),
      ], for: probeService)

    peripheral.discoverCharacteristics(
      [
        CBUUID(string: DeviceInformationManufacturerNameCharacteristicUUID),
        CBUUID(string: DeviceInformationModelNumberCharacteristicUUID),
        CBUUID(string: DeviceInformationSerialNumberCharacteristicUUID),
        CBUUID(string: DeviceInformationFirmwareRevisionCharacteristicUUID),
      ], for: deviceInformationService)
  }

  public func peripheral(
    _ peripheral: CBPeripheral,
    didDiscoverCharacteristicsFor service: CBService, error: (any Error)?
  ) {
    logger.info("Discovered characteristics")
    guard let connectionAttempt = self.connectionAttempts[peripheral.identifier]
    else {
      return
    }

    // Assume we discovered once all services have at least one characteristic
    if let services = peripheral.services {
      for service in services {
        guard let characteristics = service.characteristics else {
          return
        }

        if characteristics.count == 0 {
          return
        }
      }
    }
    connectionAttempt.resume()
    self.connectionAttempts[peripheral.identifier] = nil
  }

  public func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: (any Error)?
  ) {
    // NOTE: Changing delegate of the peripheral doesn't seem to work, simply
    // relay all calls
    guard let connection = self.connections[peripheral.identifier] else {
      return
    }

    connection.peripheral(
      peripheral, didUpdateNotificationStateFor: characteristic, error: error)
  }

  public func peripheral(
    _ peripheral: CBPeripheral,
    didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?
  ) {
    // NOTE: Changing delegate of the peripheral doesn't seem to work, simply
    // relay all calls
    guard let connection = self.connections[peripheral.identifier] else {
      return
    }

    connection.peripheral(
      peripheral, didUpdateValueFor: characteristic, error: error)
  }
}
