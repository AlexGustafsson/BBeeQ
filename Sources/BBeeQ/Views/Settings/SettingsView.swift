import SwiftUI

struct SettingsView: View {
  @State private var autoConnect = true

  var body: some View {
    VStack {
      Form {
        Section("General") {
          Toggle("Auto connect", isOn: $autoConnect)
        }
        Section("Advanced") {
          Button("Disconnect all probes") {

          }
          Button("Forgett all probes") {

          }
        }
      }
     .formStyle(.grouped)
     #if os(macOS)
       .padding(5)
      #endif
    }
  }
}
