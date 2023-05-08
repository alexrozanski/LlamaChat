//
//  ChatSources.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine
import SwiftUI
import DataModel
import FileManager
import ModelCompatibility
import ModelDirectory
import ModelMetadata
import ModelUtils

fileprivate class SerializedChatSourcesPayload: SerializedPayload<[ChatSource]> {
  override class var valueKey: String? { return "sources" }
  override class var currentPayloadVersion: Int { return 2 }
}

public class ChatSourcesModel: ObservableObject {
  @Published public private(set) var sources: [ChatSource] = [] {
    didSet {
      persistSources()
    }
  }

  private lazy var persistedSourcesURL: URL? = {
    return applicationSupportDirectoryURL()?.appending(path: "sources.json")
  }()

  private var subscriptions = Set<AnyCancellable>()

  public init() {
    loadSources()

    $sources
      .flatMap { sources in
        Publishers.MergeMany(sources.map { $0.objectWillChange })
      }
      .debounce(for: .zero, scheduler: RunLoop.main)
      .sink { [weak self] _ in
        self?.persistSources()
      }.store(in: &subscriptions)
  }

  public func add(source: ChatSource) {
    sources.append(source)
  }

  public func remove(source: ChatSource) {
    _ = sources.firstIndex(where: { $0 === source }).map { sources.remove(at: $0) }

    if let modelDirectoryId = source.modelDirectoryId {
      do {
        let modelDirectory = try ModelFileManager.shared.modelDirectory(with: modelDirectoryId)
        modelDirectory.cleanUp()
      } catch {
        print("WARNING: Failed to clean up model directory on remove")
      }
    }
  }

  public func moveSources(fromOffsets offsets: IndexSet, toOffset destination: Int) {
    sources.move(fromOffsets: offsets, toOffset: destination)
  }

  public func source(for id: ChatSource.ID) -> ChatSource? {
    return sources.first(where: { $0.id == id })
  }

  // MARK: - Persistence

  private func loadSources() {
    guard
      let persistedURL = persistedSourcesURL,
      FileManager.default.fileExists(atPath: persistedURL.path)
    else { return }

    do {
      let jsonData = try Data(contentsOf: persistedURL)
      let decoder = JSONDecoder()
      decoder.userInfo = [
        .modelParametersCoder: LlamaFamilyModelParametersCoder(),
        .chatSourceUpgrader: self
      ]
      let payload = try decoder.decode(SerializedChatSourcesPayload.self, from: jsonData)
      sources = payload.value
    } catch {
      print("Error loading sources:", error)
    }
  }

  private func persistSources() {
    guard let persistedURL = persistedSourcesURL else { return }

    let encoder = JSONEncoder()
    encoder.userInfo = [
      .modelParametersCoder: LlamaFamilyModelParametersCoder()
    ]
    do {
      let json = try encoder.encode(SerializedChatSourcesPayload(value: sources))
      print(try String(data: json, encoding: .utf8))
//      try json.write(to: persistedURL)
    } catch {
      print("Error persisting sources:", error)
    }
  }
}

private let legacyLlamaChatSourceType = "llama"
private let legacyAlpacaChatSourceType = "alpaca"
private let legacyGpt4AllChatSourceType = "gpt4all"

extension ChatSourcesModel: ChatSourceUpgrader {
  public func upgradeChatSourceToModel(chatSourceType: String, modelSize: String) throws -> (modelId: String, modelVariantId: String?) {
    switch chatSourceType {
    case legacyLlamaChatSourceType:
      switch modelSize {
      case "size7B":
        return (BuiltinMetadataModels.llama.id, BuiltinMetadataModels.llama.variant7BId)
      case "size13B":
        return (BuiltinMetadataModels.llama.id, BuiltinMetadataModels.llama.variant13BId)
      case "size30B":
        return (BuiltinMetadataModels.llama.id, BuiltinMetadataModels.llama.variant30BId)
      case "size65B":
        return (BuiltinMetadataModels.llama.id, BuiltinMetadataModels.llama.variant65BId)
      default:
        return (BuiltinMetadataModels.llama.id, nil)
      }
    case legacyAlpacaChatSourceType:
      return (BuiltinMetadataModels.alpaca.id, BuiltinMetadataModels.alpaca.variantId)
    case legacyGpt4AllChatSourceType:
      return (BuiltinMetadataModels.gpt4all.id, BuiltinMetadataModels.gpt4all.variantId)
    default:
      throw ChatSourceUpgradeError.invalidChatSourceType
    }
  }
}
