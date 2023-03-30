//
//  ComposeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation

class ComposeViewModel: ObservableObject {
  private let chatModel: ChatModel

  @Published var text: String = ""

  init(chatModel: ChatModel) {
    self.chatModel = chatModel
  }

  func send(message: String) {
    chatModel.append(message: Message(content: message, sender: .me))
    text = ""
    chatModel.append(message: Message(content: "This is a reply", sender: .other))
  }
}
