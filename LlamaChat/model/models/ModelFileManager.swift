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
      try FileManager.default.removeItem(at: url)
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
}
