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
    return chatModel.messages.map { MessageViewModel(message: $0) }
  }

  private var subscriptions = Set<AnyCancellable>()

  init(chatModel: ChatModel) {
    self.chatModel = chatModel
    chatModel.$messages.sink { _ in self.objectWillChange.send() }.store(in: &subscriptions)
  }
}
