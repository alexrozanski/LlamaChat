//
//  SelectSourceTypeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class SelectSourceTypeViewModel: ObservableObject {
  typealias SelectSourceHandler = (ChatSourceType) -> Void

  struct Source {
    let id: String
    let type: ChatSourceType
    let name: String
    let description: String
  }

  @Published var sources: [Source]

  private let chatSources: ChatSources
  private let selectSourceHandler: SelectSourceHandler

  init(chatSources: ChatSources, selectSourceHandler: @escaping SelectSourceHandler) {
    self.chatSources = chatSources
    self.selectSourceHandler = selectSourceHandler

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
      case .gpt4All:
        return Source(
          id: type.rawValue,
          type: type,
          name: "GPT4All",
          description: "Nomic AI's assistant-style LLM based on LLaMa"
        )
      }
    }
  }

  func select(sourceType: ChatSourceType) {
    selectSourceHandler(sourceType)
  }
}
