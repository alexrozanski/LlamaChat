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

  private let message: Message

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

  init(message: Message) {
    self.message = message
    content = message.content.value
    message.content.sink(receiveCompletion: { _ in }, receiveValue: { content in
      self.content = content
    }).store(in: &subscriptions)
  }
}
