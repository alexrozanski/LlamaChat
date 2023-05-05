// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "Downloads",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "Downloads",
      targets: ["Downloads"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
    .package(path: "../FileManager")
  ],
  targets: [
    .target(
      name: "Downloads",
      dependencies: ["Alamofire", "FileManager"]
    )
  ]
)
