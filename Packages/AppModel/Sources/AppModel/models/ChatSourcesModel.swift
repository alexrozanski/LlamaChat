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
import ModelDirectory
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

  private lazy var persistedURL: URL? = {
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

  private func loadSources() {
    guard
      let persistedURL,
      FileManager.default.fileExists(atPath: persistedURL.path)
    else { return }

    do {
      let jsonData = try Data(contentsOf: persistedURL)
      let decoder = JSONDecoder()
      decoder.userInfo = [
        .defaultModelParametersProvider: { defaultModelParameters(for: $0) }
      ]
      let payload = try decoder.decode(SerializedChatSourcesPayload.self, from: jsonData)
      sources = payload.value
    } catch {
      print("Error loading sources:", error)
    }
  }

  private func persistSources() {
    guard let persistedURL else { return }

    let jsonEncoder = JSONEncoder()
    do {
      let json = try jsonEncoder.encode(SerializedChatSourcesPayload(value: sources))
      try json.write(to: persistedURL)
    } catch {
      print("Error persisting sources:", error)
    }
  }
}
