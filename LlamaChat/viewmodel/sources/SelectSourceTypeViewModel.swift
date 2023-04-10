//
//  SelectSourceTypeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class SelectSourceTypeViewModel: ObservableObject {
  typealias SelectSourceHandler = (ChatSourceType) -> Void

  struct Source: Equatable {
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

    sources = [ChatSourceType.alpaca, ChatSourceType.gpt4All, ChatSourceType.llama].map { type in
      switch type {
      case .llama:
        return Source(
          id: type.rawValue,
          type: type,
          name: "Llama",
          description: "The OG Facebook LLaMA model"
        )
      case .alpaca:
        return Source(
          id: type.rawValue,
          type: type,
          name: "Alpaca",
          description: "Stanford's Alpaca model: a fine-tuned instruction-following LLaMA model"
        )
      case .gpt4All:
        return Source(
          id: type.rawValue,
          type: type,
          name: "GPT4All",
          description: "Nomic AI's assistant-style LLM based on LLaMA"
        )
      }
    }
  }

  func select(sourceType: ChatSourceType) {
    selectSourceHandler(sourceType)
  }
}
