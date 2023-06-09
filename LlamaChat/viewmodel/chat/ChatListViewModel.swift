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
  var modelDescription: String {
    var suffix: String
    switch chatSource.modelSize {
    case .unknown: suffix = ""
    case .size7B: suffix = " (7B)"
    case .size13B: suffix = " (13B)"
    case .size30B: suffix = " (30B)"
    case .size65B: suffix = " (65B)"
    }

    return "\(chatSource.type.readableName)\(suffix)"
  }
  @Published var title: String

  private var subscriptions = Set<AnyCancellable>()

  private(set) lazy var avatarViewModel = AvatarViewModel(chatSource: chatSource)

  private weak var chatListViewModel: ChatListViewModel?

  fileprivate init(chatSource: ChatSource, chatListViewModel: ChatListViewModel) {
    self.chatSource = chatSource
    self.chatListViewModel = chatListViewModel
    self.title = chatSource.name
    chatSource.$name.sink(receiveValue: { [weak self] newName in
      self?.title = newName
    }).store(in: &subscriptions)
  }

  func remove() {
    chatListViewModel?.removeSource(chatSource)
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

    items = []
    items = chatSources.sources.map { ChatListItemViewModel(chatSource: $0, chatListViewModel: self) }

    chatSources.$sources.sink(receiveValue: { newSources in
      self.items = newSources.map { ChatListItemViewModel(chatSource: $0, chatListViewModel: self) }
    }).store(in: &subscriptions)
    mainChatViewModel.$selectedSourceId.sink(receiveValue: { newSelectedSourceId in
      self.selectedSourceId = newSelectedSourceId
    }).store(in: &subscriptions)
  }

  func selectSource(with id: String?) {
    mainChatViewModel?.selectedSourceId = id
  }

  func removeSource(_ source: ChatSource) {
    mainChatViewModel?.removeChatSource(source)
  }

  func itemViewModel(with sourceId: String?) -> ChatListItemViewModel? {
    guard let sourceId else { return nil }
    return items.first(where: { $0.id == sourceId })
  }
}
