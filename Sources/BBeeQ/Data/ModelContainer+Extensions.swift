import SwiftData

extension ModelContainer {
  static func initDefault() throws -> ModelContainer {
      // TODO: For now - store only in-memory
      let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

    return try ModelContainer(
      for: Probe.self,
      configurations: configuration)
  }
}
