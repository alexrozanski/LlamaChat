//
//  ChatSourcesViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine

class ChatSourceViewModel: ObservableObject {
  let title: String

  fileprivate init(title: String) {
    self.title = title
  }
}

class ChatSourcesViewModel: ObservableObject {
  private let chatSources: ChatSources
  private var subscriptions = Set<AnyCancellable>()

  @Published private(set) var sources: [ChatSourceViewModel]

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
    self.sources = chatSources.sources.map { ChatSourceViewModel(title: $0.name) }
    chatSources.$sources.sink(receiveValue: { newSources in
      self.sources = newSources.map { ChatSourceViewModel(title: $0.name) }
    }).store(in: &subscriptions)
  }
}
