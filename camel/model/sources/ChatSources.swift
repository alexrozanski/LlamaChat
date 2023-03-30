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

class ChatSources: ObservableObject {
  @Published private(set) var sources: [ChatSource] = [] {
    didSet {
      guard let persistedURL else { return }

      let jsonEncoder = JSONEncoder()
      let json = try? jsonEncoder.encode(Payload(sources: sources))
      try? json?.write(to: persistedURL)

      print(persistedURL)
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

  private func loadSources() {
    guard
      let persistedURL,
      let jsonData = try? Data(contentsOf: persistedURL),
      let payload = try? JSONDecoder().decode(Payload.self, from: jsonData)
    else { return }

    sources = payload.sources
  }
}
