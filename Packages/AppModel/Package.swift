// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "AppModel",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "AppModel",
      targets: ["AppModel"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/CameLLM/CameLLM.git", branch: "main"),
    .package(url: "https://github.com/CameLLM/CameLLM-Llama.git", branch: "main"),
    .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: Version(stringLiteral: "0.9.2")),
    .package(path: "../DataModel"),
    .package(path: "../FileManager")
  ],
  targets: [
    .target(
      name: "AppModel",
      dependencies: [
        .product(name: "CameLLM", package: "CameLLM"),
        .product(name: "CameLLMLlama", package: "CameLLM-Llama"),
        .product(name: "SQLite", package: "SQLite.swift"),
        "DataModel",
        "FileManager"
      ]
    )
  ]
)
