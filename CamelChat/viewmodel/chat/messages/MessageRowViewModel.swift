//
//  MessageRowViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import Foundation

class MessageRowViewModel {
  var messageViewModel: MessageViewModel
  private let messagesViewModel: MessagesViewModel

  var id: UUID { return messageViewModel.id }
  var sender: Sender { return messageViewModel.sender }

  init(messageViewModel: MessageViewModel, messagesViewModel: MessagesViewModel) {
    self.messageViewModel = messageViewModel
    self.messagesViewModel = messagesViewModel
  }
}
