//
//  ClearedContextMessageViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 05/04/2023.
//

import Foundation
import Combine

class ClearedContextMessageViewModel: MessageViewModel {
  var id: UUID { message.id }
  var sender: Sender { message.sender }
  var sendDate: Date { message.sendDate }

  let canCopyContents = CurrentValueSubject<Bool, Never>(false)

  private let message: ClearedContextMessage

  init(message: ClearedContextMessage) {
    self.message = message
  }

  func copyContents() {}
}
