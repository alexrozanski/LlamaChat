//
//  RemoteMetadataParser.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import Yams

fileprivate struct RemoteModelFile: Decodable {
  let model: RemoteModel
}

class RemoteMetadataParser {
  enum Error: Swift.Error {
    case invalidDirectory
    case invalidModelFile
  }

  // URL should be the directory containing the metadata files
  func parseMetadata(at url: URL) throws -> [RemoteModel] {
    let fileManager = FileManager()
    let modelsDirectory = url.appending(component: "models", directoryHint: .isDirectory)
    if !fileManager.fileExists(atPath: modelsDirectory.path) {
      throw Error.invalidDirectory
    }

    let modelFileURLs = try modelFileURLs(in: modelsDirectory)
    return try modelFileURLs.map { try decodeModel(from: $0) }
  }

  private func decodeModel(from fileURL: URL) throws -> RemoteModel {
    let data = try Data(contentsOf: fileURL)
    return try YAMLDecoder().decode(RemoteModelFile.self, from: data).model
  }

  private func modelFileURLs(in directory: URL) throws -> [URL] {
    let fileManager = FileManager()
    return try fileManager.contentsOfDirectory(atPath: directory.path).compactMap { relativePath in
      let pathExtension = (relativePath as NSString).pathExtension
      if !["yml", "yaml"].contains(pathExtension.lowercased()) {
        return nil
      }
      return directory.appending(component: relativePath)
    }
  }
}
