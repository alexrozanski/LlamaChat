//
//  SourceTypeSelectionViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class SourceTypeSelectionViewModel: ObservableObject {
  struct Source {
    let id: String
    let name: String
    let description: String
  }

  @Published var sources: [Source]

  private let chatSources: ChatSources
  init(chatSources: ChatSources) {
    self.chatSources = chatSources

    sources = ChatSourceType.allCases.map { type in
      switch type {
      case .llama:
        return Source(id: type.rawValue, name: "Llama", description: "The OG Facebook LLaMa model")
      case .alpaca:
        return Source(id: type.rawValue, name: "Alpaca", description: "Stanford's Alpaca model: a fine-tuned instruction-following LLaMa model")
      }
    }
  }
}
