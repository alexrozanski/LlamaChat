// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "ChatUI",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ChatUI",
      targets: ["ChatUI"]
    )
  ],
  dependencies: [
    .package(path: "../AddSourceUI"),
    .package(path: "../AppModel"),
    .package(path: "../ChatInfoUI"),
    .package(path: "../ModelCompatibilityUI"),
    .package(path: "../SettingsUI")
  ],
  targets: [
    .target(
      name: "ChatUI",
      dependencies: [
        "AddSourceUI",
        "AppModel",
        "ChatInfoUI",
        "ModelCompatibilityUI",
        "SettingsUI"
      ]
    )
  ]
)
