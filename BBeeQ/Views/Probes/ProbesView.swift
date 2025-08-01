import BBQProbeE
import CoreBluetooth
import SwiftData
import SwiftUI

struct ProbesView: View {
  @Query(sort: \Probe.id) var probes: [Probe]
  @Environment(\.probePeripheralManager) var probePeripheralManager:
    ProbePeripheralManager?

  @State var presentAddProbeSheet: Bool = false

  @State private var discoveredSelection = Set<UUID>()

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      ScrollView {
        // TODO: Draggable to move within list
        ForEach(probes) { probe in
          ProbeView(
            probe: probe
          )
          .padding()
        }

        if probes.count == 0 {
          Text("No probes. Probes are automatically added when they are found.")
            .frame(
              maxWidth: .infinity, alignment: .center
            )
            .padding(10).font(.callout).foregroundStyle(.secondary)
        }
      }
      .scrollContentBackground(.hidden)
      .background(.clear)
      #if os(iOS)
        .background(Color(UIColor.systemGroupedBackground))
      #endif

      // FAB to add probes
      Button {
        presentAddProbeSheet = true
      } label: {
        Image(systemName: "thermometer.medium")
          .font(.title.weight(.semibold))
          .padding()
          .background(Color.pink)
          .foregroundColor(.white)
          .clipShape(Circle())
          .shadow(radius: 4, x: 0, y: 4)
      }
      .buttonStyle(PlainButtonStyle())
      .overlay {
        let allProbes =
          if let probePeripheralManager = self.probePeripheralManager {
            Array(probePeripheralManager.discovered.values)
          } else {
            [CBPeripheral]()
          }
        let newProbes = allProbes.filter { peripheral in
          !probes.contains(where: { probe in
            peripheral.identifier.uuidString == probe.id
          })
        }
        CountBadge(value: newProbes.count)
          .offset(x: 20, y: -20)
      }
      .padding()
      .sheet(isPresented: $presentAddProbeSheet) {
        // Do nothing
      } content: {
        AddProbesView()
          #if os(macOS)
            .frame(width: 520)
          #endif
      }
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

  return ProbesView()
    .modelContainer(container)
}
