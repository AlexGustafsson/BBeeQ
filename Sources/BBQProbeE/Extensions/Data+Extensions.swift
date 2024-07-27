import Foundation

extension Data {
    var hex: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

extension Data {
  var ascii: String? {
    return  String(data: self, encoding: .ascii)
  }
}

extension Data {
 func uint16le(at: Int) -> UInt16 {
    // TODO: Validate length, return optional
    return (UInt16(self[at+1]) << 8) | UInt16(self[at])
  }
}
