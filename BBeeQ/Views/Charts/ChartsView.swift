import BBQProbeE
import Charts
import SwiftData
import SwiftUI

struct TemperatureOverTime {
  var date: Date
  var temperature: Float
}

struct ChartsView: View {
  @State var presentAddProbesSheet: Bool = false

  @Query(sort: \Probe.id) var probes: [Probe]

  var body: some View {
    ZStack {
      ScrollView {
        ForEach(probes) { probe in
          ProbeChartView(
            probe: probe
          )
        }

        // TODO: A single grill card with average and min max area
        // ruler
      }
      .scrollContentBackground(.hidden)
      .background(.clear)
      #if os(iOS)
        .background(Color(UIColor.systemGroupedBackground))
      #endif
      if probes.count == 0 {
        VStack {
          Spacer()
          Image(systemName: "thermometer.medium.slash").font(.title)
            .foregroundColor(Color.pink)
          Text("No probes added yet.")
          Button {
            presentAddProbesSheet.toggle()
          } label: {
            Text("Add probes")
          }
          .frame(
            maxWidth: .infinity, alignment: .center
          )
          .padding(10)
          Spacer()
        }
      }
    }
    .sheet(isPresented: $presentAddProbesSheet) {
      // Do nothing
    } content: {
      AddProbesView()
        #if os(macOS)
          .frame(width: 520)
        #endif
    }
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Probe.self, configurations: config)

  let probe = Probe(
    id: "1", name: "Probe 1", temperatureTarget: 70, grillTemperatureTarget: 300
  )
  container.mainContext.insert(probe)

  return ChartsView()
    .modelContainer(container)
}
