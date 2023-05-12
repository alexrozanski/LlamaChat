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
    .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),
    .package(url: "https://github.com/CameLLM/CameLLM.git", branch: "main"),
    .package(url: "https://github.com/CameLLM/CameLLM-Llama.git", branch: "main"),
    .package(path: "../DataModel"),
  ],
  targets: [
    .target(
      name: "ModelCompatibility",
      dependencies: [
        .product(name: "CameLLM", package: "CameLLM"),
        .product(name: "CameLLMLlama", package: "CameLLM-Llama"),
        "DataModel"
      ]
    )
  ]
)
