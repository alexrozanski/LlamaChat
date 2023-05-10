// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "CardUI",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "CardUI",
      targets: ["CardUI"]
    )
  ],
  dependencies: [
    .package(path: "../SharedUI")
  ],
  targets: [
    .target(
      name: "CardUI",
      dependencies: [
        "SharedUI"
      ]
    )
  ]
)
