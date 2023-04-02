//
//  ChatViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation

class ChatViewModel: ObservableObject {
  private let chatSource: ChatSource
  private let chatModel: ChatModel

  var sourceId: String {
    chatModel.source.id
  }

  private(set) lazy var composeViewModel = ComposeViewModel(chatModel: chatModel)
  private(set) lazy var infoViewModel = ChatInfoViewModel(chatSource: chatSource)
  private(set) lazy var messagesViewModel = MessagesViewModel(chatModel: chatModel)


  init(chatSource: ChatSource, messagesModel: MessagesModel) {
    self.chatSource = chatSource
    self.chatModel = ChatModel(source: chatSource, messagesModel: messagesModel)
  }
}
