//
//  ChatSourcesViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine

class ChatListItemViewModel: ObservableObject {
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

class ChatListViewModel: ObservableObject {
  private let chatSources: ChatSources
  private weak var mainChatViewModel: MainChatViewModel?

  @Published private(set) var items: [ChatListItemViewModel]
  @Published private(set) var selectedSourceId: String?

  private var subscriptions = Set<AnyCancellable>()

  init(chatSources: ChatSources, mainChatViewModel: MainChatViewModel) {
    self.chatSources = chatSources
    self.mainChatViewModel = mainChatViewModel
    self.items = chatSources.sources.map { ChatListItemViewModel(chatSource: $0) }

    chatSources.$sources.sink(receiveValue: { newSources in
      self.items = newSources.map { ChatListItemViewModel(chatSource: $0) }
    }).store(in: &subscriptions)
    mainChatViewModel.$selectedSourceId.sink(receiveValue: { newSelectedSourceId in
      self.selectedSourceId = newSelectedSourceId
    }).store(in: &subscriptions)
  }

  func selectSource(with id: String?) {
    mainChatViewModel?.selectedSourceId = id
  }

  func itemViewModel(with sourceId: String?) -> ChatListItemViewModel? {
    guard let sourceId else { return nil }
    return items.first(where: { $0.id == sourceId })
  }
}
