//
//  ChatViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import AppModel
import DataModel

class ChatViewModel: ObservableObject {
  private let chatSource: ChatSource
  private let chatModels: ChatModels
  private let chatModel: ChatModel

  var sourceId: String {
    chatModel.source.id
  }

  var sourceName: String {
    chatModel.source.name
  }

  private(set) lazy var composeViewModel = ComposeViewModel(chatModel: chatModel)
  private(set) lazy var infoViewModel = ChatInfoViewModel(chatModel: chatModel)
  private(set) lazy var messagesViewModel = MessagesViewModel(chatModel: chatModel)


  init(chatSource: ChatSource, chatModels: ChatModels, messagesModel: MessagesModel) {
    self.chatSource = chatSource
    self.chatModels = chatModels
    self.chatModel = chatModels.chatModel(for: chatSource)
  }
}
