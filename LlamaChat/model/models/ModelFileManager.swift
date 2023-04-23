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

  func moveFileIntoDirectory(from sourceURL: URL) throws -> URL {
    let dest = url.appending(path: sourceURL.lastPathComponent)
    try FileManager.default.moveItem(at: sourceURL, to: dest)
    return dest
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
  enum Error: Swift.Error {
    case failedToGetModelsDirectoryURL
    case failedToMakeNewModelDirectory
    case modelDirectoryDoesNotExist
  }

  static let shared = ModelFileManager()

  private init() {}

  private func modelsDirectoryURL() throws -> URL {
    guard let applicationSupportDirectory = applicationSupportDirectoryURL() else {
      throw Error.failedToGetModelsDirectoryURL
    }
    return applicationSupportDirectory.appendingPathComponent("models")
  }

  func modelDirectory(with id: ModelDirectory.ID) throws -> ModelDirectory {
    let modelDirectory = try modelDirectoryURL(for: id)
    if !FileManager.default.fileExists(atPath: modelDirectory.path) {
      throw Error .modelDirectoryDoesNotExist
    }
    return ModelDirectory(id: id, url: modelDirectory)
  }

  func makeNewModelDirectory() throws -> ModelDirectory {
    let id = UUID().uuidString
    let modelDirectory = try modelDirectoryURL(for: id)
    do {
      try FileManager.default.createDirectory(at: modelDirectory, withIntermediateDirectories: true)
    } catch {
      throw Error.failedToMakeNewModelDirectory
    }
    return ModelDirectory(id: id, url: modelDirectory)
  }

  private func modelDirectoryURL(for id: ModelDirectory.ID) throws -> URL {
    let modelsDirectory = try modelsDirectoryURL()
    return modelsDirectory.appendingPathComponent(id, isDirectory: true)
  }

  // Fixes any issues caused by https://github.com/alexrozanski/LlamaChat/issues/10
  func cleanUpUnquantizedModelFiles() {
    guard let modelsDirectoryURL = try? modelsDirectoryURL() else {
      print("WARNING: Couldn't clean up unquantized model files")
      return
    }

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
