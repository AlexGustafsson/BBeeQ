import BBQProbeE
import Foundation
import SwiftData

extension ProbePeripheral {
  func fetchDescriptor() -> FetchDescriptor<Probe> {
    let peripheralId = self.id.uuidString
    return FetchDescriptor<Probe>(
      predicate: #Predicate { $0.id == peripheralId })
  }
}
