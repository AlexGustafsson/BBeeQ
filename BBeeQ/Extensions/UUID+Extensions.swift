import CryptoKit
import Foundation

extension UUID {
  init(fromHash data: String) {
    var digest = [UInt8](SHA256.hash(data: data.data(using: .utf8)!)).prefix(16)

    // version 48-51 (1000)
    digest[6] = 0b1000 << 4 | digest[6] & 0xF
    // variant 64-66 (10)
    digest[8] = 0b10 << 6 | digest[8] & 0x3F

    var hex = digest.map({ String(format: "%02X", $0) }).joined()
    hex.insert("-", at: hex.index(hex.startIndex, offsetBy: 8))
    hex.insert("-", at: hex.index(hex.startIndex, offsetBy: 13))
    hex.insert("-", at: hex.index(hex.startIndex, offsetBy: 18))
    hex.insert("-", at: hex.index(hex.startIndex, offsetBy: 23))

    self.init(uuidString: hex)!
  }
}
