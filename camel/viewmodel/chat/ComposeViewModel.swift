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
    chatModel.append(message: StaticMessage(content: message, sender: .me))
    text = ""
  }
}
