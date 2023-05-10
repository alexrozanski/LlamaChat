// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "ChatInfoUI",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ChatInfoUI",
      targets: ["ChatInfoUI"]
    )
  ],
  dependencies: [
    .package(path: "../AppModel"),
    .package(path: "../DataModel"),
    .package(path: "../SettingsUI"),
    .package(path: "../SharedUI")
  ],
  targets: [
    .target(
      name: "ChatInfoUI",
      dependencies: [
        "AppModel",
        "DataModel",
        "SettingsUI",
        "SharedUI"
      ]
    )
  ]
)
