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
  dependencies: [
    .package(path: "../AppModel"),
    .package(path: "../DataModel")
  ],
  targets: [
    .target(
      name: "SharedUI",
      dependencies: [
        "AppModel",
        "DataModel"
      ]
    )
  ]
)
