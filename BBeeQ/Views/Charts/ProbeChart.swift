import Charts
import SwiftUI

struct ProbeChart: View {
  @State var connected = false

  // TODO: auto compaction - second to minute resolution - use average for readings
  let data: [TemperatureOverTime] = [Int](0...20)
    .map {
      TemperatureOverTime(
        date: Date.now.advanced(by: -TimeInterval($0 * 60)),
        temperature: Float.random(in: 20...26))
    }
  let prediction: [TemperatureOverTime] = [Int](0...20)
    .map {
      TemperatureOverTime(
        date: Date.now.advanced(by: TimeInterval($0 * 60)),
        temperature: Float.random(in: 1...5) + (Float($0) / 20) * 50 + 20)
    }

  var body: some View {
    Chart {
      // Target horizontal line
      RuleMark(y: .value("Target", 70))
        .lineStyle(StrokeStyle(lineWidth: 1, dash: [3])).foregroundStyle(.red)

      // Data
      ForEach(data, id: \.date) { item in
        LineMark(
          x: .value("Date", item.date),
          y: .value("Temperature", item.temperature),
          series: .value("Probe", "1")
        )
        .foregroundStyle(.red)
      }

      // Prediction
      ForEach(prediction, id: \.date) { item in
        LineMark(
          x: .value("Date", item.date),
          y: .value("Temperature", item.temperature)
        )
        .foregroundStyle(.gray.opacity(0.5))
      }

      // Now point
      PointMark(
        x: .value("Date", Date.now),
        y: .value("Temperature", data.last!.temperature)
      )
      .symbol {
        PulsatingCircle(animate: connected)
          .frame(width: 12)
      }

    }
    .padding()
    .chartXAxis {
      AxisMarks(values: .automatic(desiredCount: 3)) { value in
        AxisGridLine(centered: true, stroke: StrokeStyle(dash: [1, 2]))
        AxisTick(
          centered: true, length: 4,
          stroke: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        AxisValueLabel(format: .dateTime.hour().minute(), anchor: .center)
      }
      AxisMarks(values: .stride(by: .minute)) { value in
        AxisTick(
          centered: true, length: 1,
          stroke: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
      }
    }
    .chartYAxis {
      AxisMarks { value in
        AxisGridLine()
        AxisValueLabel {
          Text("\(value.as(Int.self)!)°C")
        }
      }
    }

    .chartOverlay { proxy in
      GeometryReader { geometry in
        Rectangle().fill(.clear).contentShape(Rectangle())
          .gesture(
            DragGesture()
              .onChanged { value in
                // Convert the gesture location to the coordinate space of the plot area.
                let origin = geometry[proxy.plotFrame!].origin
                let location = CGPoint(
                  x: value.location.x - origin.x,
                  y: value.location.y - origin.y
                )
                // Get the x (date) and y (price) value from the location.
                let (date, price) = proxy.value(
                  at: location, as: (Date, Float).self)!
                print("Location: \(date), \(price)")
              }
          )
          .onContinuousHover { phase in
            switch phase {
            case .active(let location):
              // Get the x (date) and y (price) value from the location.
              let (date, price) = proxy.value(
                at: location, as: (Date, Float).self)!
              print("Location: \(date), \(price)")
            case .ended:
              break
            }
          }
      }
    }
  }
}

#Preview {
  ScrollView {
    ProbeChart().padding()
  }
}
