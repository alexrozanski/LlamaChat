//
//  StaticMessageViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation

class StaticMessageViewModel: MessageViewModel {
  private let message: StaticMessage

  var id: UUID { message.id }
  var content: String {
    return message.content
  }
  var sender: Sender { message.sender }
  var isError: Bool { message.isError }

  init(message: StaticMessage) {
    self.message = message
  }
}
