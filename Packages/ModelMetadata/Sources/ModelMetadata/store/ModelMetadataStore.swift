//
//  ModelMetadataStore.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import DataModel

private let supportedMetadataVersion = "v1"

public class ModelMetadataStore {
  enum Error: Swift.Error {
    case unableToFetchMetadata
  }

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

  private(set) lazy var gitFetcher: MetadataFetcher = GitBasedMetadataFetcher(
    repositoryURL: URL(string: "git@github.com:alexrozanski/llamachat-models.git")!,
    version: supportedMetadataVersion
  )
  private(set) lazy var fallbackFetcher = FileBasedMetadataFetcher(version: supportedMetadataVersion)

  public private(set) var initialModels: [Model]?
  @Published private(set) public var fetchState: FetchState = .none

  public init() {
    do {
      if let repositoryDirectory = gitFetcher.cachedMetadataURL {
        let parser = MetadataParser()
        initialModels = try parser.parseMetadata(at: repositoryDirectory)
      }
    } catch {
      // Nothing to do here as repository may not have been initialized yet.
    }
  }

  public func fetchMetadata() async throws -> [Model] {
    guard !fetchState.isFetching else { return [] }

    fetchState = .fetching

    do {
      let models = try await _fetchMetadata()
      await MainActor.run {
        fetchState = .succeeded
      }
      return models
    } catch {
      print(error)
      await MainActor.run {
        fetchState = .failed
      }
      throw error
    }
  }

  private func _fetchMetadata() async throws -> [Model] {
    var metadataDirectory: URL?
    do {
      metadataDirectory = try await gitFetcher.fetchUpdatedMetadata()
    } catch {
      do {
        metadataDirectory = try await fallbackFetcher.fetchUpdatedMetadata()
      } catch {
        throw Error.unableToFetchMetadata
      }
    }

    guard let metadataDirectory else {
      throw Error.unableToFetchMetadata
    }

    return try MetadataParser().parseMetadata(at: metadataDirectory)
  }
}
