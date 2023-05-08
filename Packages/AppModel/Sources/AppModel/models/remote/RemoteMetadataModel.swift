//
//  RemoteMetadataModel.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import DataModel
import ModelMetadata

public class RemoteMetadataModel: ObservableObject {
  public enum LoadState {
    case none
    case loading
    case loaded
    case failed
  }

  let apiBaseURL: URL

  @Published private(set) public var allModels: [Model] = []
  @Published private(set) public var loadState: LoadState = .none

  private lazy var store = RemoteModelMetadataMetadataStore()

  public init(apiBaseURL: URL) {
    self.apiBaseURL = apiBaseURL

    allModels = remoteFallbackModels()

    store.$allModels
      .assign(to: &$allModels)

    store.$fetchState
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
    store.updateMetadata()
  }
}
