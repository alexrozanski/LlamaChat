// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "ModelCompatibilityUI",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ModelCompatibilityUI",
      targets: ["ModelCompatibilityUI"]
    )
  ],
  dependencies: [
    .package(path: "../ModelCompatibility"),
    .package(path: "../AppModel"),
    .package(path: "../ChatInfoUI"),
    .package(path: "../DataModel"),
    .package(path: "../SettingsUI")
  ],
  targets: [
    .target(
      name: "ModelCompatibilityUI",
      dependencies: [
        "ChatInfoUI",
        "AppModel",
        "DataModel",
        "ModelCompatibility",
        "SettingsUI"
      ]
    )
  ]
)
