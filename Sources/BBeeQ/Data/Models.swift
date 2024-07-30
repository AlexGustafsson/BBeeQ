import SwiftData

@Model final class Probe: Identifiable {
  var id: String

  @Transient var temperature: Double = 0
  var temperatureTarget: Double

  @Transient var grillTemperature: Double = 0
  var grillTemperatureTarget: Double

  init(id: String, temperatureTarget: Double, grillTemperatureTarget: Double) {
    self.id = id

    self.temperatureTarget = temperatureTarget

    self.grillTemperatureTarget = grillTemperatureTarget
  }
}
