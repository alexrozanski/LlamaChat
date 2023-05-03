//
//  SelectSourceTypeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import DataModel

class SelectSourceTypeViewModel: ObservableObject {
  typealias SelectSourceHandler = (ChatSourceType) -> Void

  struct Source {
    let id: String
    let type: ChatSourceType
    let name: String
    let description: String
    let learnMoreLink: URL?
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
          name: "LLaMA",
          description: "The original Facebook LLaMA Large Language Model",
          learnMoreLink: URL(string: "https://github.com/facebookresearch/llama")
        )
      case .alpaca:
        return Source(
          id: type.rawValue,
          type: type,
          name: "Alpaca",
          description: "Stanford's Alpaca model: a fine-tuned instruction-following LLaMA model",
          learnMoreLink: URL(string: "https://github.com/tatsu-lab/stanford_alpaca")
        )
      case .gpt4All:
        return Source(
          id: type.rawValue,
          type: type,
          name: "GPT4All",
          description: "Nomic AI's assistant-style LLM based on LLaMA",
          learnMoreLink: URL(string: "https://github.com/nomic-ai/gpt4all")
        )
      }
    }
  }

  func select(sourceType: ChatSourceType) {
    selectSourceHandler(sourceType)
  }
}
