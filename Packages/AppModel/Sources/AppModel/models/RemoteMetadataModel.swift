//
//  RemoteMetadataModel.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import DataModel
import RemoteModels

public class RemoteMetadataModel: ObservableObject {
  public enum LoadState {
    case none
    case loading
    case loaded
    case failed
  }

  let apiBaseURL: URL

  @Published private(set) public var allModels: [RemoteModel] = []
  @Published private(set) public var loadState: LoadState = .none

  private lazy var fetcher = RemoteModelMetadataFetcher()

  public init(apiBaseURL: URL) {
    self.apiBaseURL = apiBaseURL

    fetcher.$allModels
      .assign(to: &$allModels)

    fetcher.$fetchState
      .map { fetchState -> LoadState in
        switch fetchState {
        case .none: return .none
        case .fetching: return .loading
        case .succeeded: return .loaded
        case .failed: return .failed
        }
      }
      .assign(to: &$loadState)
  }

  public func fetchMetadata() {
    fetcher.updateMetadata()
  }
}
