// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "SettingsUI",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "SettingsUI",
      targets: ["SettingsUI"]
    )
  ],
  dependencies: [
    .package(path: "../AddSourceUI"),
    .package(path: "../AppModel"),
    .package(path: "../SharedUI")
  ],
  targets: [
    .target(
      name: "SettingsUI",
      dependencies: [
        "AddSourceUI",
        "AppModel",
        "SharedUI"
      ]
    )
  ]
)
