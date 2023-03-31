//
//  ChatModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine

class ChatModel: ObservableObject {
  private let source: ChatSource

  @Published var messages = [Message]()

  init(source: ChatSource) {
    self.source = source
  }

  func append(message: Message) {
    messages.append(message)
  }
}
