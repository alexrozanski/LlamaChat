//
//  GitBasedMetadataStore.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import Combine
import FileManager

class MetadataStore {
  private(set) lazy var gitFetcher: MetadataFetcher = GitBasedMetadataFetcher(repositoryURL: URL(string: "git@github.com:alexrozanski/llamachat-models.git")!)
  private(set) lazy var fallbackFetcher = FileBasedMetadataFetcher(url: URL(string: "https://github.com/alexrozanski/llamachat-models/archive/refs/heads/main.zip")!)

  let models = CurrentValueSubject<[RemoteModel], Never>([])

  init() {
    do {
      if let repositoryDirectory {
        let parser = RemoteMetadataParser()
        models.send(try parser.parseMetadata(at: repositoryDirectory))
      }
    } catch {
      // Nothing to do here as repository may not have been initialized yet.
    }
  }

  func updateMetadata() async throws {
    do {
      models.send(try await gitFetcher.updateMetadata())
    } catch {
      models.send(try await fallbackFetcher.updateMetadata())
    }
  }

  private var repositoryDirectory: URL? {
    return cachesDirectoryURL()?.appending(component: "llamachat-models")
  }
}
