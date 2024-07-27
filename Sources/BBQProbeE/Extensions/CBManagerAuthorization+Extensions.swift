import CoreBluetooth

extension CBManagerAuthorization {
  var debugDescription: String {
    switch self {
      case .allowedAlways:
        return "allowed always"
      case .denied:
        return "denied"
      case .notDetermined:
        return "not determined"
      case .restricted:
        return "restricted"
      default:
        return String(self.rawValue)
    }
  }
}
