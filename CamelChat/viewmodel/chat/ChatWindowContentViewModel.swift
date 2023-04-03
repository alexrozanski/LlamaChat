//
//  MainChatViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine

class MainChatViewModel: ObservableObject {
  enum RestorableKey: String {
    case sidebarWidth
    case selectedSourceId
  }

  private let chatSources: ChatSources
  private let chatModels: ChatModels
  private let messagesModel: MessagesModel
  private let restorableData: any RestorableData<RestorableKey>

  @Published var selectedSourceId: String? {
    didSet {
      restorableData.set(value: selectedSourceId, for: .selectedSourceId)
    }
  }
  @Published var sidebarWidth: Double? {
    didSet {
      restorableData.set(value: sidebarWidth, for: .sidebarWidth)
    }
  }

  lazy private(set) var chatListViewModel = ChatListViewModel(chatSources: chatSources, mainChatViewModel: self)

  private var subscriptions = Set<AnyCancellable>()

  init(
    chatSources: ChatSources,
    chatModels: ChatModels,
    messagesModel: MessagesModel,
    stateRestoration: StateRestoration
  ) {
    self.chatSources = chatSources
    self.chatModels = chatModels
    self.messagesModel = messagesModel
    self.restorableData = stateRestoration.restorableData(for: "ChatWindow")
    _sidebarWidth = Published(initialValue: restorableData.getValue(for: .sidebarWidth) ?? 200)
    _selectedSourceId = Published(initialValue: restorableData.getValue(for: .selectedSourceId) ?? chatSources.sources.first?.id)
    chatSources.$sources.scan(nil as [ChatSource]?) { [weak self] (previousSources, newSources) in
      if newSources.count == 1 && (previousSources?.isEmpty ?? true) {
        self?.selectedSourceId = newSources.first?.id
      }
      return newSources
    }.sink { _ in }.store(in: &subscriptions)
  }  

  func makeChatViewModel(for sourceId: String) -> ChatViewModel? {
    guard let chatSource = chatSources.sources.first(where: { $0.id == sourceId }) else { return nil }
    return ChatViewModel(chatSource: chatSource, chatModels: chatModels, messagesModel: messagesModel)
  }
}
