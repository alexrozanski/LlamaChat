//
//  ChatSources.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

fileprivate struct Payload: Codable {
  let sources: [ChatSource]
}

class ChatSource: Codable, ObservableObject {
  typealias ID = String

  let id: ID
  @Published var name: String {
    didSet {
      chatSources?.didUpdate(self)
    }
  }
  @Published var avatarImageName: String? {
    didSet {
      chatSources?.didUpdate(self)
    }
  }
  let type: ChatSourceType
  let modelURL: URL
  let modelDirectoryId: ModelDirectory.ID?
  let modelSize: ModelSize

  fileprivate weak var chatSources: ChatSources?

  enum CodingKeys: CodingKey {
    case id
    case name
    case avatarImageName
    case type
    case modelURL
    case modelDirectoryId
    case modelSize
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    id = try values.decode(String.self, forKey: .id)
    name = try values.decode(String.self, forKey: .name)
    avatarImageName = try values.decode(String.self, forKey: .avatarImageName)
    type = try values.decode(ChatSourceType.self, forKey: .type)
    modelURL = try values.decode(URL.self, forKey: .modelURL)
    modelDirectoryId = try values.decode(ModelDirectory.ID?.self, forKey: .modelDirectoryId)
    modelSize = try values.decode(ModelSize.self, forKey: .modelSize)
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
  }

  init(
    name: String,
    avatarImageName: String?,
    type: ChatSourceType,
    modelURL: URL,
    modelDirectoryId: ModelDirectory.ID?,
    modelSize: ModelSize
  ) {
    self.id = UUID().uuidString
    self.name = name
    self.avatarImageName = avatarImageName
    self.type = type
    self.modelURL = modelURL
    self.modelDirectoryId = modelDirectoryId
    self.modelSize = modelSize
  }
}

class ChatSources: ObservableObject {
  @Published private(set) var sources: [ChatSource] = [] {
    didSet {
      persistSources()
    }
  }

  private lazy var persistedURL: URL? = {
    return applicationSupportDirectoryURL()?.appending(path: "sources.json")
  }()

  init() {
    loadSources()
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

  fileprivate func didUpdate(_ source: ChatSource) {
    persistSources()
    objectWillChange.send()
  }

  private func loadSources() {
    guard let persistedURL else { return }

    do {
      let jsonData = try Data(contentsOf: persistedURL)
      let payload = try JSONDecoder().decode(Payload.self, from: jsonData)

      payload.sources.forEach { source in
        source.chatSources = self
      }
      sources = payload.sources
    } catch {
      print("Error loading sources:", error)
    }
  }

  private func persistSources() {
    guard let persistedURL else { return }

    let jsonEncoder = JSONEncoder()
    let json = try? jsonEncoder.encode(Payload(sources: sources))
    try? json?.write(to: persistedURL)
  }
}
