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

  #if DEBUG
  let isBuiltForDebug = true
  #else
  let isBuiltForDebug = false
  #endif

  @Published var messages: [MessageViewModel]

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

private func makeViewModels(from messages: [Message], in messagesViewModel: MessagesViewModel) -> [MessageViewModel] {
  return messages.compactMap { message in
    if let staticMessage = message as? StaticMessage {
      return StaticMessageViewModel(message: staticMessage)
    } else if let generatedMessage = message as? GeneratedMessage {
      return GeneratedMessageViewModel(message: generatedMessage)
    } else if let clearedContextMessage = message as? ClearedContextMessage {
      return ClearedContextMessageViewModel(message: clearedContextMessage)
    } else {
      print("Unsupported message type for \(message)")
      return nil
    }
  }
}
