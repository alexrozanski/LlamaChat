// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "AddSourceUI",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "AddSourceUI",
      targets: ["AddSourceUI"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/CameLLM/CameLLM.git", branch: "main"),
    .package(url: "https://github.com/CameLLM/CameLLM-Llama.git", branch: "main"),
    .package(path: "../AppModel"),
    .package(path: "../CardUI"),
    .package(path: "../Downloads"),
    .package(path: "../ModelDirectory"),
    .package(path: "../ModelMetadata"),
    .package(path: "../SharedUI")
  ],
  targets: [
    .target(
      name: "AddSourceUI",
      dependencies: [
        .product(name: "CameLLM", package: "CameLLM"),
        .product(name: "CameLLMLlama", package: "CameLLM-Llama"),
        "AppModel",
        "CardUI",
        "Downloads",
        "ModelDirectory",
        "ModelMetadata",
        "SharedUI"
      ]
    )
  ]
)
