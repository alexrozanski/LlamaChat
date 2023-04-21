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
  static let shared = ModelFileManager()

  private init() {}

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

  // Fixes any issues caused by https://github.com/alexrozanski/LlamaChat/issues/10
  func cleanUpUnquantizedModelFiles() {
    guard let modelsDirectoryURL else { return }

    let enumerator = FileManager.default.enumerator(at: modelsDirectoryURL, includingPropertiesForKeys: nil, options: [])
    enumerator?.forEach { itemURL in
      guard let itemURL = itemURL as? URL else { return }

      // This is hardcoded by the conversion script
      let unquantizedModelName = "ggml-model-f16.bin"

      if itemURL.lastPathComponent == unquantizedModelName {
        do {
          try FileManager.default.removeItem(at: itemURL)
        } catch {
          print("WARNING: Couldn't clean up unquantized model at", itemURL)
        }
      }
    }
  }
}
