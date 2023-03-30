//
//  ChatModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine

class ChatModel: ObservableObject {
  @Published var messages = [Message]()

  func append(message: Message) {
    messages.append(message)
  }
}
