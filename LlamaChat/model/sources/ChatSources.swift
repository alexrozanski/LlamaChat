//
//  ChatSources.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine

fileprivate struct Payload: Codable {
  let sources: [ChatSource]
}

class ChatSource: Codable, ObservableObject {
  typealias ID = String

  let id: ID

  @Published var name: String
  @Published var avatarImageName: String?

  let type: ChatSourceType
  let modelURL: URL
  let modelDirectoryId: ModelDirectory.ID?
  let modelSize: ModelSize
  @Published private(set) var modelParameters: ModelParameters

  private var subscriptions = Set<AnyCancellable>()

  init(
    name: String,
    avatarImageName: String?,
    type: ChatSourceType,
    modelURL: URL,
    modelDirectoryId: ModelDirectory.ID?,
    modelSize: ModelSize,
    modelParameters: ModelParameters
  ) {
    self.id = UUID().uuidString
    self.name = name
    self.avatarImageName = avatarImageName
    self.type = type
    self.modelURL = modelURL
    self.modelDirectoryId = modelDirectoryId
    self.modelSize = modelSize
    self.modelParameters = modelParameters

    setUpObservation()
  }

  // MARK: - Codable

  enum CodingKeys: CodingKey {
    case id
    case name
    case avatarImageName
    case type
    case modelURL
    case modelDirectoryId
    case modelSize
    case modelParameters
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    id = try values.decode(String.self, forKey: .id)
    name = try values.decode(String.self, forKey: .name)
    avatarImageName = try values.decode(String?.self, forKey: .avatarImageName)
    type = try values.decode(ChatSourceType.self, forKey: .type)
    modelURL = try values.decode(URL.self, forKey: .modelURL)
    modelDirectoryId = try values.decode(ModelDirectory.ID?.self, forKey: .modelDirectoryId)
    modelSize = try values.decode(ModelSize.self, forKey: .modelSize)

    // These were added after the initial release.
    let modelParameters = try values.decodeIfPresent(ModelParameters.self, forKey: .modelParameters)
    self.modelParameters = modelParameters ?? defaultModelParameters(for: type)

    setUpObservation()
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(avatarImageName, forKey: .avatarImageName)
    try container.encode(type, forKey: .type)
    try container.encode(modelURL, forKey: .modelURL)
    try container.encode(modelDirectoryId, forKey: .modelDirectoryId)
    try container.encode(modelSize, forKey: .modelSize)
    try container.encode(modelParameters, forKey: .modelParameters)
  }

  func resetDefaultParameters() {
    self.modelParameters = defaultModelParameters(for: type)
  }

  // MARK: - Private

  private func setUpObservation() {
    $name.receive(on: DispatchQueue.main).sink { [weak self] _ in
      self?.objectWillChange.send()
    }.store(in: &subscriptions)

    $avatarImageName.receive(on: DispatchQueue.main).sink { [weak self] _ in
      self?.objectWillChange.send()
    }.store(in: &subscriptions)

    modelParameters.objectWillChange.sink { [weak self] _ in
      self?.objectWillChange.send()
    }.store(in: &subscriptions)
  }
}

// MARK: -

class ChatSources: ObservableObject {
  @Published private(set) var sources: [ChatSource] = [] {
    didSet {
      persistSources()
    }
  }

  private lazy var persistedURL: URL? = {
    return applicationSupportDirectoryURL()?.appending(path: "sources.json")
  }()

  private var subscriptions = Set<AnyCancellable>()

  init() {
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

  func add(source: ChatSource) {
    sources.append(source)
  }

  func remove(source: ChatSource) {
    _ = sources.firstIndex(where: { $0 === source }).map { sources.remove(at: $0) }
    if let modelDirectoryId = source.modelDirectoryId, let modelDirectory = ModelFileManager().modelDirectory(with: modelDirectoryId) {
      modelDirectory.cleanUp()
    }
  }

  func source(for id: ChatSource.ID) -> ChatSource? {
    return sources.first(where: { $0.id == id })
  }

  private func loadSources() {
    guard
      let persistedURL,
      FileManager.default.fileExists(atPath: persistedURL.path)
    else { return }

    do {
      let jsonData = try Data(contentsOf: persistedURL)
      let payload = try JSONDecoder().decode(Payload.self, from: jsonData)
      sources = payload.sources
    } catch {
      print("Error loading sources:", error)
    }
  }

  private func persistSources() {
    guard let persistedURL else { return }

    let jsonEncoder = JSONEncoder()
    do {
      let json = try jsonEncoder.encode(Payload(sources: sources))
      try json.write(to: persistedURL)
    } catch {
      print("Error persisting sources:", error)
    }
  }
}
