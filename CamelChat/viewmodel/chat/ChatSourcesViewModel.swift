//
//  ChatSourcesViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine

class ChatSourceViewModel: ObservableObject {
  private let chatSource: ChatSource

  var id: String { chatSource.id }
  @Published var title: String

  private var subscriptions = Set<AnyCancellable>()

  fileprivate init(chatSource: ChatSource) {
    self.chatSource = chatSource
    self.title = chatSource.name
    chatSource.$name.sink(receiveValue: { [weak self] newName in
      self?.title = newName
    }).store(in: &subscriptions)
  }
}

class ChatSourcesViewModel: ObservableObject {
  private let chatSources: ChatSources
  private var subscriptions = Set<AnyCancellable>()

  @Published private(set) var sources: [ChatSourceViewModel]

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
    self.sources = chatSources.sources.map { ChatSourceViewModel(chatSource: $0) }
    chatSources.$sources.sink(receiveValue: { newSources in
      self.sources = newSources.map { ChatSourceViewModel(chatSource: $0) }
    }).store(in: &subscriptions)
  }

  func chatSourceViewModel(with sourceId: String?) -> ChatSourceViewModel? {
    guard let sourceId else { return nil }
    return sources.first(where: { $0.id == sourceId })
  }
}
