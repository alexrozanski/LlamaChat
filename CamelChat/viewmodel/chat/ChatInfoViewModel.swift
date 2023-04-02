//
//  ChatInfoViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import Foundation

class ChatInfoViewModel: ObservableObject {
  enum ModelStat<V> {
    case none
    case loading
    case value(V)

    func map<U>(_ transform: (_ value: V) -> ModelStat<U>) -> ModelStat<U> {
      switch self {
      case .none: return .none
      case .loading: return .loading
      case .value(let value): return transform(value)
      }
    }
  }

  private let chatModel: ChatModel

  var name: String {
    chatModel.source.name
  }

  var modelType: String {
    switch chatModel.source.type {
    case .llama:
      return "LLaMA model"
    case .alpaca:
      return "Alpaca model"
    }
  }

  @Published private(set) var context: ModelStat<String> = .none
  @Published private(set) var contextTokenCount: ModelStat<Int> = .none

  init(chatModel: ChatModel) {
    self.chatModel = chatModel
  }

  func loadModelStats() {
    context = .loading
    contextTokenCount = .loading

    Task.init {
      let context = await chatModel.loadContext()
      await MainActor.run {
        self.context = context.contextString.map { .value($0) } ?? .none
        let tokenCount = context.tokens?.count
        self.contextTokenCount = tokenCount.map { .value($0) } ?? .none
      }
    }
  }
}
