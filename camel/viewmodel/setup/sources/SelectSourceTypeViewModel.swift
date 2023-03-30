//
//  SelectSourceTypeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class SelectSourceTypeViewModel: ObservableObject {
  struct Source {
    let id: String
    let type: ChatSourceType
    let name: String
    let description: String
  }

  @Published var sources: [Source]

  weak var setupViewModel: SetupViewModel?

  private let chatSources: ChatSources
  init(chatSources: ChatSources, setupViewModel: SetupViewModel) {
    self.chatSources = chatSources
    self.setupViewModel = setupViewModel

    sources = ChatSourceType.allCases.map { type in
      switch type {
      case .llama:
        return Source(
          id: type.rawValue,
          type: type,
          name: "Llama",
          description: "The OG Facebook LLaMa model"
        )
      case .alpaca:
        return Source(
          id: type.rawValue,
          type: type,
          name: "Alpaca",
          description: "Stanford's Alpaca model: a fine-tuned instruction-following LLaMa model"
        )
      }
    }
  }

  func select(sourceType: ChatSourceType) {
    setupViewModel?.configureSource(with: sourceType)
  }
}
