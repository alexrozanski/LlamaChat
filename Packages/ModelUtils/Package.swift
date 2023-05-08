// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "ModelUtils",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ModelUtils",
      targets: ["ModelUtils"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/CameLLM/CameLLM.git", branch: "main"),
    .package(url: "https://github.com/CameLLM/CameLLM-Llama.git", branch: "main"),
    .package(path: "../DataModel"),
    .package(path: "../ModelCompatibility")
  ],
  targets: [
    .target(
      name: "ModelUtils",
      dependencies: [
        .product(name: "CameLLM", package: "CameLLM"),
        .product(name: "CameLLMLlama", package: "CameLLM-Llama"),
        "DataModel",
        "ModelCompatibility"
      ]
    )
  ]
)
