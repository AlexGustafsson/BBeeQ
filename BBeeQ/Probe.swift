import SwiftData

@Model final class Probe: Identifiable {
  @Attribute(.unique) var id: String

  var name: String

  var temperatureTarget: Double
  var grillTemperatureTarget: Double

  init(
    id: String, name: String, temperatureTarget: Double,
    grillTemperatureTarget: Double
  ) {
    self.id = id
    self.name = name
    self.temperatureTarget = temperatureTarget
    self.grillTemperatureTarget = grillTemperatureTarget
  }
}
