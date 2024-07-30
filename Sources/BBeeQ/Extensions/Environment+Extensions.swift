import SwiftUI
import BBQProbeE

extension EnvironmentValues {
  // TODO: Use @Entry of Swift 6?
  var probePeripheralManager: ProbePeripheralManager? {
    get { self[ProbePeripheralManagerKey.self] }
    set { self[ProbePeripheralManagerKey.self] = newValue }
  }
}

private struct ProbePeripheralManagerKey: EnvironmentKey {
  static let defaultValue: ProbePeripheralManager? = nil
}
