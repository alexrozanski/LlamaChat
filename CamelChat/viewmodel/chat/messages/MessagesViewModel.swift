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

  var messages: [MessageViewModel] {
    return chatModel.messages.compactMap { message in
      if let staticMessage = message as? StaticMessage {
        return StaticMessageViewModel(message: staticMessage)
      } else if let generatedMessage = message as? GeneratedMessage {
        return GeneratedMessageViewModel(message: generatedMessage)
      } else {
        return nil
      }
    }
  }

  private var subscriptions = Set<AnyCancellable>()

  init(chatModel: ChatModel) {
    self.chatModel = chatModel
    chatModel.$messages.sink { _ in self.objectWillChange.send() }.store(in: &subscriptions)
  }
}
