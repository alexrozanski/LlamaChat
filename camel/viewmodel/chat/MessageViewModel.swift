//
//  MessageViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation
import Combine

class MessageViewModel: ObservableObject {
  var id: UUID { message.id }

  private let message: any Message

  @Published var content: String = ""

  var isMe: Bool {
    switch message.sender {
    case .me:
      return true
    case .other:
      return false
    }
  }

  private var subscriptions = Set<AnyCancellable>()

  init(message: any Message) {
    self.message = message
    content = message.content
    message.contentDidChange.sink(receiveValue: {
      self.content = message.content
    }).store(in: &subscriptions)
  }
}
