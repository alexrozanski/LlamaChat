//
//  ModelFileManager.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 10/04/2023.
//

import Foundation

class ModelDirectory {
  typealias ID = String

  let id: ID
  let url: URL

  private var hasCleanedUp = false

  fileprivate init(id: ID, url: URL) {
    self.id = id
    self.url = url
  }

  func cleanUp() {
    do {
      guard !hasCleanedUp else { return }

      try FileManager.default.removeItem(at: url)
      hasCleanedUp = true
    } catch {
      print("WARNING: failed to clean up model directory")
    }
  }
}

class ModelFileManager {
  private var modelsDirectoryURL: URL? {
    return applicationSupportDirectoryURL()?.appendingPathComponent("models")
  }

  func modelDirectory(with id: ModelDirectory.ID) -> ModelDirectory? {
    guard let modelDirectory = modelDirectoryURL(for: id) else { return nil }
    return ModelDirectory(id: id, url: modelDirectory)
  }

  func makeNewModelDirectory() throws -> ModelDirectory? {
    let id = UUID().uuidString
    guard let modelDirectory = modelDirectoryURL(for: id) else { return nil }
    try FileManager.default.createDirectory(at: modelDirectory, withIntermediateDirectories: true)

    return ModelDirectory(id: id, url: modelDirectory)
  }

  private func modelDirectoryURL(for id: ModelDirectory.ID) -> URL? {
    guard let modelsDirectory = modelsDirectoryURL else { return nil }
    return modelsDirectory.appendingPathComponent(id, isDirectory: true)
  }
}
