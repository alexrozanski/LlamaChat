// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "ModelDirectory",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ModelDirectory",
      targets: ["ModelDirectory"]
    )
  ],
  dependencies: [
    .package(path: "../FileManager")
  ],
  targets: [
    .target(
      name: "ModelDirectory",
      dependencies: ["FileManager"]
    )
  ]
)
