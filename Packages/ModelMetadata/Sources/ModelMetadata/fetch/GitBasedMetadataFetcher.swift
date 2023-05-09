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
  }

  let repositoryURL: URL
  init(repositoryURL: URL) {
    self.repositoryURL = repositoryURL
  }

  func updateMetadata() async throws -> [Model] {
    guard let repositoryDirectory else {
      return []
    }

    guard try await Process.init(command: Process.Command("which", arguments: ["git"])).run().isSuccess else {
      throw Error.gitMissing
    }

    try await cloneIfNeeded()
    try await update(in: repositoryDirectory)

    let metadataParser = MetadataParser()
    return try metadataParser.parseMetadata(at: repositoryDirectory)
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
    try await Process.init(command: Process.Command("git", arguments: ["-C", repositoryDirectory.path, "pull", "-f"])).run()
  }

  private var repositoryDirectory: URL? {
    return cachesDirectoryURL()?.appending(component: "model-metadata")
  }
}
