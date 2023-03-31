//
//  ChatViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation

class ChatViewModel: ObservableObject {
  private let chatModel: ChatModel
  private let chatSources: ChatSources

  private(set) lazy var chatSourcesViewModel = ChatSourcesViewModel(chatSources: chatSources)
  private(set) lazy var composeViewModel = ComposeViewModel(chatModel: chatModel)
  private(set) lazy var messagesViewModel = MessagesViewModel(chatModel: chatModel)

  init(chatModel: ChatModel, chatSources: ChatSources) {
    self.chatModel = chatModel
    self.chatSources = chatSources
  }
}
