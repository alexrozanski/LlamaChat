// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "ModelMetadata",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "ModelMetadata",
      targets: ["ModelMetadata"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.0.0")),
    .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.5"),
    .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0")),
    .package(url: "https://github.com/binarybirds/git-kit", from: "1.0.0"),
    .package(path: "../DataModel"),
    .package(path: "../Downloads"),
    .package(path: "../FileManager")
  ],
  targets: [
    .target(
      name: "ModelMetadata",
      dependencies: [
        .product(name: "GitKit", package: "git-kit"),
        "Alamofire",
        "Yams",
        "ZIPFoundation",
        "DataModel",
        "Downloads",
        "FileManager"
      ]
    )
  ]
)
