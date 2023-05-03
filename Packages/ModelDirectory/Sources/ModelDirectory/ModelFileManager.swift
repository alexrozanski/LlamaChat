//
//  ModelFileManager.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 10/04/2023.
//

import Foundation
import FileManager

public class ModelFileManager {
  enum Error: Swift.Error {
    case failedToGetModelsDirectoryURL
    case failedToMakeNewModelDirectory
    case modelDirectoryDoesNotExist
  }

  public static let shared = ModelFileManager()

  private init() {}

  private func modelsDirectoryURL() throws -> URL {
    guard let applicationSupportDirectory = applicationSupportDirectoryURL() else {
      throw Error.failedToGetModelsDirectoryURL
    }
    return applicationSupportDirectory.appendingPathComponent("models")
  }

  public func modelDirectory(with id: ModelDirectory.ID) throws -> ModelDirectory {
    let modelDirectory = try modelDirectoryURL(for: id)
    if !FileManager.default.fileExists(atPath: modelDirectory.path) {
      throw Error .modelDirectoryDoesNotExist
    }
    return ModelDirectory(id: id, url: modelDirectory)
  }

  public func makeNewModelDirectory() throws -> ModelDirectory {
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
  public func cleanUpUnquantizedModelFiles() {
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
