//
//  GitBasedMetadataFetcher.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import GitKit
import FileManager

class GitBasedMetadataFetcher: MetadataFetcher {
  let repositoryURL: URL
  init(repositoryURL: URL) {
    self.repositoryURL = repositoryURL
  }

  func updateMetadata() async throws -> [RemoteModel] {
    guard let repositoryDirectory else {
      return []
    }

    try cloneIfNeeded()

    let git = Git(path: repositoryDirectory.path)
    try git.run(.pull())

    let metadataParser = RemoteMetadataParser()
    return try metadataParser.parseMetadata(at: repositoryDirectory)
  }

  private func cloneIfNeeded() throws {
    guard let repositoryDirectory else { return }

    let fileManager = FileManager()
    if !fileManager.fileExists(atPath: repositoryDirectory.path) {
      let enclosingDirectory = repositoryDirectory.deletingLastPathComponent()
      let git = Git(path: enclosingDirectory.path)
      try git.run(.clone(url: repositoryURL.absoluteString))
    }
  }

  private var repositoryDirectory: URL? {
    return cachesDirectoryURL()?.appending(component: "llamachat-models")
  }
}
