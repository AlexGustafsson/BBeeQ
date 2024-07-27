import CoreBluetooth

extension CBManagerState {
  var debugDescription: String {
    switch self {
      case .poweredOff:
        return "powered off"
      case .poweredOn:
        return "powered on"
      case .resetting:
        return "resetting"
      case .unauthorized:
        return "unauthorized"
      case .unknown:
        return "unknown"
      case .unsupported:
        return "unsupported"
      default:
        return String(self.rawValue)
    }
  }
}
