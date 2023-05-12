// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "DataModel",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "DataModel",
      targets: ["DataModel"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),
    .package(path: "../FileManager")
  ],
  targets: [
    .target(
      name: "DataModel",
      dependencies: [
        "AnyCodable",
        "FileManager"
      ]
    )
  ]
)
