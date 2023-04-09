//
//  ClearedContextMessageViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 05/04/2023.
//

import Foundation

class ClearedContextMessageViewModel: MessageViewModel {
  var id: UUID { message.id }
  var sender: Sender { message.sender }
  var sendDate: Date { message.sendDate }

  private let message: ClearedContextMessage

  init(message: ClearedContextMessage) {
    self.message = message
  }
}
