//
//  RemoteModelMetadataFetcher.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public class RemoteModelMetadataFetcher {
  public enum FetchState {
    case none
    case fetching
    case succeeded
    case failed

    var isFetching: Bool {
      switch self {
      case .none, .succeeded, .failed:
        return false
      case .fetching:
        return true
      }
    }
  }

  @Published public private(set) var allModels: [RemoteModel] = []

  @Published private(set) public var fetchState: FetchState = .none

  private let _fetcher: MetadataFetcher

  public init() {
    _fetcher = GitBasedMetadataFetcher(repositoryURL: URL(string: "git@github.com:alexrozanski/llamachat-models.git")!)
  }

  public func updateMetadata() {
    guard !fetchState.isFetching else { return }

    fetchState = .fetching

    Task.init {
      do {
        let models = try await _fetcher.updateMetadata()
        allModels = models
        await MainActor.run {
          fetchState = .succeeded
        }
      } catch {
        do {
          allModels = try await updateMetadataWithFallbackFetcher()
          await MainActor.run {
            fetchState = .succeeded
          }
        } catch {
          print(error)
          await MainActor.run {
            fetchState = .failed
          }
        }
      }
    }
  }

  private func updateMetadataWithFallbackFetcher() async throws -> [RemoteModel] {
    let fileBasedFetcher = FileBasedMetadataFetcher(url: URL(string: "https://github.com/alexrozanski/llamachat-models/archive/refs/heads/main.zip")!)
    return try await fileBasedFetcher.updateMetadata()
  }
}
