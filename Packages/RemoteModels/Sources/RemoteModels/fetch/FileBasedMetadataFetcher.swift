//
//  FileBasedMetadataFetcher.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import Downloads
import ZIPFoundation

struct ResponsePayload: Decodable {
  let models: [RemoteModel]
}

class FileBasedMetadataFetcher: MetadataFetcher {
  private let url: URL

  private var downloadHandle: DownloadHandle?

  init(url: URL) {
    self.url = url
  }

  func updateMetadata() async throws -> [RemoteModel] {
    return try await withCheckedThrowingContinuation { continuation in
      downloadHandle = DownloadsManager.shared.downloadFile(
        from: URL(string: "https://camellm.org/llamachat-models-main.zip")!,
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

              let parser = RemoteMetadataParser()
              let models = try parser.parseMetadata(at: directory)
              continuation.resume(returning: models)
            } catch {
              continuation.resume(throwing: error)
            }
          case .failure(let error):
            print(error)
          }
        },
        resultsHandlerQueue: .main
      )
    }
  }
}
