//
//  DownloadsManager.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import Alamofire

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

  func downloadFile(from url: URL, progressHandler: ((Progress) -> Void)?) async throws -> URL {
    let downloadsDirectoryURL = try self.downloadsDirectoryURL(create: true)
    let downloadDirectoryURL = downloadsDirectoryURL.appending(path: UUID().uuidString, directoryHint: .isDirectory)

    let destination: DownloadRequest.Destination = { _, _ in
      let fileURL = downloadDirectoryURL.appending(path: url.lastPathComponent, directoryHint: .notDirectory)
      print(fileURL)
      return (fileURL, [.createIntermediateDirectories])
    }

    return try await withCheckedThrowingContinuation { continuation in
      AF.download(url.absoluteString, to: destination)
        .downloadProgress(queue: .main) { progress in
          progressHandler?(progress)
        }
        .responseURL { response in
          switch response.result {
          case .success(let url):
            continuation.resume(returning: url)
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
    }
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
