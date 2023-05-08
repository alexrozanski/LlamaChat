// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "ModelCompatibility",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ModelCompatibility",
      targets: ["ModelCompatibility"]
    )
  ],
  dependencies: [
    .package(path: "../DataModel")
  ],
  targets: [
    .target(
      name: "ModelCompatibility",
      dependencies: [
        "DataModel"
      ]
    )
  ]
)
