// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "SharedUI",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "SharedUI",
      targets: ["SharedUI"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "SharedUI",
      dependencies: []
    )
  ]
)
