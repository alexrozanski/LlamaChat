//
//  ChatViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Combine
import SwiftUI
import AppModel
import ChatInfoUI
import DataModel
import ModelCompatibility
import ModelCompatibilityUI

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

  private(set) var parametersViewModel = CurrentValueSubject<ModelParametersViewModel?, Never>(nil)

  private var subscriptions = Set<AnyCancellable>()

  init(chatSource: ChatSource, chatModels: ChatModels, messagesModel: MessagesModel) {
    self.chatSource = chatSource
    self.chatModels = chatModels
    let chatModel = chatModels.chatModel(for: chatSource)
    self.chatModel = chatModel

    chatSource.$modelParameters
      .map { makeParametersViewModel(from: $0, chatModel: chatModel) }
      .sink { [weak self] viewModel in
        self?.parametersViewModel.send(viewModel)
        self?.objectWillChange.send()
      }
      .store(in: &subscriptions)
  }
}
