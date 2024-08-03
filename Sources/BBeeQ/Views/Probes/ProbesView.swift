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
            .frame(
              width: .infinity)
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
        let newProbes = Array(probePeripheralManager!.discovered.values)
          .filter { peripheral in
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
