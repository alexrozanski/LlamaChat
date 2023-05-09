//
//  FileBasedMetadataFetcher.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import DataModel
import Downloads
import ZIPFoundation

struct ResponsePayload: Decodable {
  let models: [Model]
}

class FileBasedMetadataFetcher: MetadataFetcher {
  private var downloadHandle: DownloadHandle?

  private let version: String
  init(version: String) {
    self.version = version
  }

  var cachedMetadataURL: URL? {
    // The download directory is temporary between runs
    return nil
  }

  func fetchUpdatedMetadata() async throws -> URL {
    return try await withCheckedThrowingContinuation { continuation in
      downloadHandle = DownloadsManager.shared.downloadFile(
        from: URL(string: "https://github.com/alexrozanski/llamachat-models/archive/refs/heads/\(version).zip")!,
        progressHandler: nil,
        resultsHandler: { result in
          switch result {
          case .success(let url):
            do {
              let baseURL = url.deletingLastPathComponent()
              let unzipURL = baseURL.appending(component: "unzipped", directoryHint: .isDirectory)
              let fileManager = FileManager()
              try fileManager.unzipItem(at: url, to: unzipURL)

              let contents = try fileManager.contentsOfDirectory(atPath: unzipURL.path).map { unzipURL.appending(component: $0) }
              guard let directory = contents.first(where: { url in
                var isDirectory: ObjCBool = false
                fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)
                return isDirectory.boolValue
              }) else {
                return
              }

              continuation.resume(returning: directory)
            } catch {
              continuation.resume(throwing: error)
            }
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        },
        resultsHandlerQueue: .main
      )
    }
  }
}
