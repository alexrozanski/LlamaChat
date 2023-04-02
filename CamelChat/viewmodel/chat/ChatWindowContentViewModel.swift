//
//  MainChatViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation

class MainChatViewModel: ObservableObject {
  enum RestorableKey: String {
    case sidebarWidth
    case selectedSourceId
  }

  private let chatSources: ChatSources
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

  lazy private(set) var chatSourcesViewModel = ChatSourcesViewModel(chatSources: chatSources)

  init(
    chatSources: ChatSources,
    messagesModel: MessagesModel,
    stateRestoration: StateRestoration
  ) {
    self.chatSources = chatSources
    self.messagesModel = messagesModel
    self.restorableData = stateRestoration.restorableData(for: "ChatWindow")
    _sidebarWidth = Published(initialValue: restorableData.getValue(for: .sidebarWidth) ?? 200)
    _selectedSourceId = Published(initialValue: restorableData.getValue(for: .selectedSourceId) ?? chatSourcesViewModel.sources.first?.id)
  }

  func makeChatViewModel(for sourceId: String) -> ChatViewModel? {
    guard let chatSource = chatSources.sources.first(where: { $0.id == sourceId }) else { return nil }
    return ChatViewModel(chatSource: chatSource, messagesModel: messagesModel)
  }
}
