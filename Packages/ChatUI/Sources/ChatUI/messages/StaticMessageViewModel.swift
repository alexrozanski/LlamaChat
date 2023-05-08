//
//  StaticMessageViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit
import Foundation
import Combine
import DataModel

class StaticMessageViewModel: MessageViewModel {
  private let message: StaticMessage

  var id: UUID { message.id }
  var content: String {
    return message.content
  }
  var sender: Sender { message.sender }
  var isError: Bool { message.isError }

  let canCopyContents = CurrentValueSubject<Bool, Never>(true)

  init(message: StaticMessage) {
    self.message = message
  }

  func copyContents() {
    NSPasteboard.general.prepareForNewContents()
    NSPasteboard.general.setString(content, forType: .string)
  }
}
