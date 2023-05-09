//
//  GitBasedMetadataStore.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import Combine
import DataModel
import FileManager

private let supportedMetadataVersion = "v1"

class MetadataStore {
  enum Error: Swift.Error {
    case unableToFetchMetadata
  }

  private(set) lazy var gitFetcher: MetadataFetcher = GitBasedMetadataFetcher(
    repositoryURL: URL(string: "git@github.com:alexrozanski/llamachat-models.git")!,
    version: supportedMetadataVersion
  )
  private(set) lazy var fallbackFetcher = FileBasedMetadataFetcher(version: supportedMetadataVersion)

  let models = CurrentValueSubject<[Model], Never>([])

  init() {
    do {
      if let repositoryDirectory = gitFetcher.cachedMetadataURL {
        let parser = MetadataParser()
        models.send(try parser.parseMetadata(at: repositoryDirectory))
      }
    } catch {
      // Nothing to do here as repository may not have been initialized yet.
    }
  }

  func updateMetadata() async throws {
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

    let parser = MetadataParser()
    models.send(try parser.parseMetadata(at: metadataDirectory))
  }
}