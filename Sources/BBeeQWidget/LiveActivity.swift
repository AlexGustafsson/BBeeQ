import ActivityKit
import SwiftUI
import WidgetKit

public struct ProbeActivityAttributes: ActivityAttributes {
  public struct ContentState: Codable, Hashable {
    public let probeTemperature: Double
    public let grillTemperature: Double

    public init(probeTemperature: Double, grillTemperature: Double) {
      self.probeTemperature = probeTemperature
      self.grillTemperature = grillTemperature
    }
  }

  public init() {

  }
}

struct ProbeLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: ProbeActivityAttributes.self) { context in
      // Lock screen/banner UI goes here
      LiveActivityView(state: context.state)
    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded UI goes here.  Compose the expanded UI through
        // various regions, like leading/trailing/center/bottom
        DynamicIslandExpandedRegion(.leading) {
          Text("LE")
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text("TR")
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text("BO")
        }
        DynamicIslandExpandedRegion(.center) {
          Text("CE")
        }
      } compactLeading: {
        Text("\(context.state.probeTemperature.formatted(.number))°C")
      } compactTrailing: {
        Text("\(context.state.grillTemperature.formatted(.number))°C")
      } minimal: {
        Image(systemName: "thermometer.medium")
      }
    }
  }
}

struct LiveActivityView: View {
  let state: ProbeActivityAttributes.ContentState

  var body: some View {
    VStack {
      Text("\(state.probeTemperature.formatted(.number))°C")
      Text("\(state.grillTemperature.formatted(.number))°C")
    }
  }
}
