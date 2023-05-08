//
//  RemoteModelMetadataMetadataStore.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import DataModel

public class RemoteModelMetadataMetadataStore {
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

  @Published public private(set) var allModels: [Model] = []

  @Published private(set) public var fetchState: FetchState = .none

  private let _store: MetadataStore

  public init() {
    _store = MetadataStore()
    _store.models.assign(to: &$allModels)
  }

  public func updateMetadata() {
    guard !fetchState.isFetching else { return }

    fetchState = .fetching

    Task.init {
      do {
        try await _store.updateMetadata()
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
