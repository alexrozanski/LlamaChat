// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "FileManager",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "FileManager",
      targets: ["FileManager"]
    )
  ],
  dependencies: [],
  targets: [
    .target(
      name: "FileManager",
      dependencies: []
    )
  ]
)
