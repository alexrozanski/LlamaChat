//
//  GitBasedMetadataFetcher.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import Coquille
import DataModel
import FileManager

class GitBasedMetadataFetcher: MetadataFetcher {
  enum Error: Swift.Error {
    case gitMissing
    case noWorkingDirectory
  }

  let repositoryURL: URL
  let version: String
  init(repositoryURL: URL, version: String) {
    self.repositoryURL = repositoryURL
    self.version = version
  }

  var cachedMetadataURL: URL? {
    return repositoryDirectory
  }

  func fetchUpdatedMetadata() async throws -> URL {
    guard let repositoryDirectory else {
      throw Error.noWorkingDirectory
    }

    guard try await Process.init(command: Process.Command("which", arguments: ["git"])).run().isSuccess else {
      throw Error.gitMissing
    }

    try await cloneIfNeeded()
    try await update(in: repositoryDirectory)

    return repositoryDirectory
  }

  private func cloneIfNeeded() async throws {
    guard let repositoryDirectory else { return }

    let fileManager = FileManager()
    if !fileManager.fileExists(atPath: repositoryDirectory.path) {
      let process = Process.init(
        command: Process.Command("git", arguments: ["clone", repositoryURL.absoluteString, repositoryDirectory.path]),
        stdout: nil,
        stderr: nil
      )
      try await process.run()
    }
  }

  private func update(in repositoryDirectory: URL) async throws {
    try await Process.init(command: Process.Command("git", arguments: ["-C", repositoryDirectory.path, "clean", "-f", "."])).run()
    try await Process.init(command: Process.Command("git", arguments: ["-C", repositoryDirectory.path, "reset", "--hard", "HEAD"])).run()
    try await Process.init(command: Process.Command("git", arguments: ["-C", repositoryDirectory.path, "fetch"])).run()
    try await Process.init(command: Process.Command("git", arguments: ["-C", repositoryDirectory.path, "checkout", version])).run()
    try await Process.init(command: Process.Command("git", arguments: ["-C", repositoryDirectory.path, "pull"])).run()
  }

  private var repositoryDirectory: URL? {
    return cachesDirectoryURL()?.appending(component: "model-metadata")
  }
}
