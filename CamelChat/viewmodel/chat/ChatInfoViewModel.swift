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
    case unknown
    case loading
    case value(V)

    func map<U>(_ transform: (_ value: V) -> ModelStat<U>) -> ModelStat<U> {
      switch self {
      case .none: return .none
      case .unknown: return .unknown
      case .loading: return .loading
      case .value(let value): return transform(value)
      }
    }

    var value: V? {
      switch self {
      case .none, .unknown, .loading:
        return nil
      case .value(let value):
        return value
      }
    }
  }

  private let chatModel: ChatModel

  var sourceId: ChatSource.ID {
    return chatModel.source.id
  }

  var name: String {
    return chatModel.source.name
  }
  
  var modelSize: String {
    switch chatModel.source.modelSize {
    case .unknown:
      return "Unknown"
    case .size7B:
      return "7B"
    case .size12B:
      return "12B"
    case .size30B:
      return "30B"
    case .size65B:
      return "65B"
    }
  }

  var modelType: String {
    switch chatModel.source.type {
    case .llama:
      return "LLaMA model"
    case .alpaca:
      return "Alpaca model"
    case .gpt4All:
      return "GPT4All model"
    }
  }

  @Published private(set) var context: ModelStat<String> = .none
  @Published private(set) var contextTokenCount: ModelStat<Int> = .none

  private(set) lazy var avatarViewModel = AvatarViewModel(chatSource: chatModel.source)

  init(chatModel: ChatModel) {
    self.chatModel = chatModel
  }

  func loadModelStats() {
    context = .loading
    contextTokenCount = .loading

    Task.init {
      do {
        let context = try await chatModel.loadContext()
        await MainActor.run {
          self.context = context.contextString.map { .value($0) } ?? .none
          let tokenCount = context.tokens?.count
          self.contextTokenCount = tokenCount.map { .value($0) } ?? .none
        }
      } catch {
        self.context = .unknown
        self.contextTokenCount = .unknown
      }
    }
  }
}
