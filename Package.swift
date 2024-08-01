// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "BBeeQ", platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .executable(name: "BBeeQ", targets: ["BBeeQ"]),
    .executable(name: "BBeeQWidget", targets: ["BBeeQWidget"]),
    .library(name: "BBQProbeE", targets: ["BBQProbeE"]),
  ],
  dependencies: [

  ],
  targets: [
    .executableTarget(
      name: "BBeeQ",
      dependencies: [
        "BBQProbeE"
      ],
      resources: [

      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", "-sectcreate",
          "-Xlinker", "__TEXT",
          "-Xlinker", "__info_plist",
          "-Xlinker", "Sources/BBeeQ/Resources/Info.plist",
        ]),
        .unsafeFlags([
          "-Xlinker", "-sectcreate",
          "-Xlinker", "__TEXT",
          "-Xlinker", "__entitlements",
          "-Xlinker", "Sources/BBeeQ/Resources/Entitlements.plist",
        ]),
      ]),
    .executableTarget(
      name: "BBeeQWidget",
      dependencies: [

      ], resources: [],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency=complete"),
        .unsafeFlags(["-Xfrontend", "-application-extension"]),
      ],
      linkerSettings: [
        .unsafeFlags([
          "-Xlinker", "-sectcreate",
          "-Xlinker", "__TEXT",
          "-Xlinker", "__info_plist",
          "-Xlinker", "Sources/BBeeQWidget/Resources/Info.plist",
        ]),
        .unsafeFlags(["-Xlinker", "-application_extension"]),
      ]),
    .target(
      name: "BBQProbeE",
      dependencies: [

      ], resources: [],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(
      name: "BBQProbeETests",
      dependencies: [
        "BBQProbeE"
      ]),
  ])
