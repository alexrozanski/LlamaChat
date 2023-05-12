//
//  RemoteMetadataModel.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import Combine
import DataModel
import ModelCompatibility
import ModelMetadata
import FileManager

fileprivate class SerializedMetadataModelsPayload: SerializedPayload<[Model]> {
  override class var valueKey: String? { return "models" }
  override class var currentPayloadVersion: Int { return 1 }
}

// Holds and manages `Model` objects which define information
// about supported models.
public class MetadataModel: ObservableObject {
  public enum LoadState {
    case none
    case loading
    case loaded
    case failed
  }

  @Published private(set) public var allModels: [Model] = BuiltinMetadataModels.all
  @Published private(set) public var loadState: LoadState = .none

  private lazy var persistedModelsURL: URL? = {
    return applicationSupportDirectoryURL()?.appending(path: "models.json")
  }()

  private lazy var store = ModelMetadataStore()
  private var subscriptions = Set<AnyCancellable>()

  public init() {
    allModels = store.initialModels ?? BuiltinMetadataModels.all

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

    if let cachedModels = loadCachedModels() {
      allModels = cachedModels
    }
  }

  public func fetchMetadata() {
    Task.init {
      do {
        let models = try await store.fetchMetadata()
        await MainActor.run {
          allModels = models
          persistModels(models)
        }
      } catch {
        print("Failed to fetch updated models")
      }
    }
  }

  // MARK: - Caching

  private func loadCachedModels() -> [Model]? {
    guard
      let persistedURL = persistedModelsURL,
      FileManager.default.fileExists(atPath: persistedURL.path)
    else { return nil }

    do {
      let jsonData = try Data(contentsOf: persistedURL)
      let decoder = JSONDecoder()
      let payload = try decoder.decode(SerializedMetadataModelsPayload.self, from: jsonData)
      return payload.value
    } catch {
      print("Error loading sources:", error)
      return nil
    }
  }

  private func persistModels(_ models: [Model]) {
    guard let persistedURL = persistedModelsURL else { return }

    let encoder = JSONEncoder()
    do {
      let json = try encoder.encode(SerializedMetadataModelsPayload(value: allModels))
      try json.write(to: persistedURL)
    } catch {
      print("Error persisting sources:", error)
    }
  }
}
