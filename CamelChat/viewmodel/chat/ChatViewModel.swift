//
//  ChatViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation

class ChatViewModel: ObservableObject {
  private let chatModel: ChatModel

  private(set) lazy var composeViewModel = ComposeViewModel(chatModel: chatModel)
  private(set) lazy var messagesViewModel = MessagesViewModel(chatModel: chatModel)

  init(chatSource: ChatSource) {
    self.chatModel = ChatModel(source: chatSource)
  }
}
