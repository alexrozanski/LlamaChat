//
//  MessagesViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine

class MessagesViewModel: ObservableObject {
  private let chatModel: ChatModel

  @Published var messages: [MessageRowViewModel]

  private var subscriptions = Set<AnyCancellable>()

  init(chatModel: ChatModel) {
    self.chatModel = chatModel
    messages = []
    messages = makeViewModels(from: chatModel.messages, in: self)
    chatModel.$messages.sink { newMessages in
      self.messages = makeViewModels(from: newMessages, in: self)
    }.store(in: &subscriptions)
  }
}

private func makeViewModels(from messages: [Message], in messagesViewModel: MessagesViewModel) -> [MessageRowViewModel] {
  messages.compactMap { message in
    var messageViewModel: MessageViewModel?
    if let staticMessage = message as? StaticMessage {
      messageViewModel = StaticMessageViewModel(message: staticMessage)
    } else if let generatedMessage = message as? GeneratedMessage {
      messageViewModel = GeneratedMessageViewModel(message: generatedMessage)
    } else {
      messageViewModel = nil
    }

    guard let messageViewModel else { return nil }
    return MessageRowViewModel(messageViewModel: messageViewModel, messagesViewModel: messagesViewModel)
  }
}
