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
    case .size12B: suffix = " (12B)"
    case .size30B: suffix = " (30B)"
    case .size65B: suffix = " (65B)"
    }

    var sourceType: String
    switch chatSource.type {
    case .llama: sourceType = "LLaMA"
    case .alpaca: sourceType = "Alpaca"
    case .gpt4All: sourceType = "GPT4All"
    }

    return "\(sourceType)\(suffix)"
  }
  @Published var title: String

  private var subscriptions = Set<AnyCancellable>()

  private(set) lazy var avatarViewModel = AvatarViewModel(chatSource: chatSource)

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
