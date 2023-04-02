//
//  ChatInfoViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import Foundation

class ChatInfoViewModel: ObservableObject {
  private let chatSource: ChatSource

  var name: String {
    chatSource.name
  }

  var modelType: String {
    switch chatSource.type {
    case .llama:
      return "LLaMA model"
    case .alpaca:
      return "Alpaca model"
    }
  }

  init(chatSource: ChatSource) {
    self.chatSource = chatSource
  }
}
