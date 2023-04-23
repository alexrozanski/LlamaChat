//
//  DownloadsManager.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import Alamofire

protocol DownloadHandle {
  func cancel()
}

fileprivate class ConcreteDownloadHandle: DownloadHandle {
  private var downloadRequest: DownloadRequest?
  init(downloadRequest: DownloadRequest?) {
    self.downloadRequest = downloadRequest
  }

  deinit {
    cancel()
  }

  func cancel() {
    if let downloadRequest {
      downloadRequest.cancel()
      self.downloadRequest = nil
    }
  }
}

class DownloadsManager {
  enum Error: Swift.Error {
    case failedToCreateDownloadsDirectory
    case failedToDownloadFile
  }

  enum ReachabilityStatus {
    case reachable(contentLength: Int64?)
    case notReachable
  }

  static var availableCapacity: Int64? {
    guard let applicationSupportDirectory = applicationSupportDirectoryURL() else { return nil }
    do {
      let values = try applicationSupportDirectory.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
      return values.volumeAvailableCapacityForImportantUsage
    } catch {
      print("Failed to determine available capacity")
      return nil
    }
  }

  static let shared = DownloadsManager()

  private init() {}

  static func checkReachability(of url: URL) async -> ReachabilityStatus {
    return await withCheckedContinuation { continuation in
      AF.request(url, method: .head).response { response in
        continuation.resume(returning: .reachable(contentLength: response.response?.expectedContentLength))
      }
    }
  }

  // Should be called on startup
  func cleanUp() {
    do {
      let downloadsDirectoryURL = try self.downloadsDirectoryURL(create: false)
      if FileManager.default.fileExists(atPath: downloadsDirectoryURL.path) {
        try FileManager.default.removeItem(at: downloadsDirectoryURL)
      }
    } catch {
      print("WARNING: Couldn't clean up downloads directory URL")
    }
  }

  // The API here is slightly different to AFNetworking - the returned DownloadHandle *must* be held onto
  // because it is used to control download cancellation (this happens automatically when it is deallocated).
  func downloadFile(
    from url: URL,
    progressHandler: ((Progress) -> Void)?,
    resultsHandler: ((Result<URL, Swift.Error>) -> Void)?,
    resultsHandlerQueue: DispatchQueue
  ) -> DownloadHandle {
    do {
      let downloadsDirectoryURL = try self.downloadsDirectoryURL(create: true)
      let downloadDirectoryURL = downloadsDirectoryURL.appending(path: UUID().uuidString, directoryHint: .isDirectory)

      let destination: DownloadRequest.Destination = { _, _ in
        let fileURL = downloadDirectoryURL.appending(path: url.lastPathComponent, directoryHint: .notDirectory)
        print(fileURL)
        return (fileURL, [.createIntermediateDirectories])
      }

      let downloadRequest = AF.download(url.absoluteString, to: destination)
        .downloadProgress(queue: .main) { progress in
          progressHandler?(progress)
        }
        .responseURL { response in
          switch response.result {
          case .success(let url):
            resultsHandlerQueue.async {
              resultsHandler?(.success(url))
            }
          case .failure(let error):
            resultsHandlerQueue.async {
              resultsHandler?(.failure(error))
            }
          }
        }
      return ConcreteDownloadHandle(downloadRequest: downloadRequest)
    } catch {
      resultsHandlerQueue.async {
        resultsHandler?(.failure(error))
      }
    }
    return ConcreteDownloadHandle(downloadRequest: nil)
  }

  // MARK: - Private

  private func downloadsDirectoryURL(create: Bool) throws -> URL {
    guard let directoryURL = cachesDirectoryURL()?.appending(path: "downloads") else {
      throw Error.failedToCreateDownloadsDirectory
    }

    if !create {
      return directoryURL
    }

    do {
      try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
      return directoryURL
    } catch {
      print("Couldn't create downloads directory:", error)
      throw Error.failedToCreateDownloadsDirectory
    }
  }
}
