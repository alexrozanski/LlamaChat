//
//  ChatInfoViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import Foundation
import Combine
import AppModel
import DataModel

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
    case .size13B:
      return "13B"
    case .size30B:
      return "30B"
    case .size65B:
      return "65B"
    }
  }

  var modelType: String {
    return "\(chatModel.source.type.readableName) model"
  }

  @Published private(set) var context: ModelStat<String> = .none
  @Published private(set) var contextTokenCount: ModelStat<Int> = .none
  @Published private(set) var canClearMessages: Bool

  // Parameters
  @Published var seedValue: Int32?
  @Published var contextSize: UInt = 0
  @Published var numberOfTokens: UInt = 0
  @Published var topP: Double = 0
  @Published var topK: UInt = 0
  @Published var temperature: Double = 0
  @Published var batchSize: UInt = 0
  @Published var lastNTokensToPenalize: UInt = 0
  @Published var repeatPenalty: Double = 0

  private(set) lazy var avatarViewModel = AvatarViewModel(chatSource: chatModel.source)

  init(chatModel: ChatModel) {
    self.chatModel = chatModel

    canClearMessages = !chatModel.messages.isEmpty

    chatModel
      .$messages
      .map { !$0.isEmpty }
      .assign(to: &$canClearMessages)

    chatModel.source.$modelParameters
      .map { $0.$seedValue }
      .switchToLatest()
      .assign(to: &$seedValue)
    chatModel.source.$modelParameters
      .map { $0.$contextSize }
      .switchToLatest()
      .assign(to: &$contextSize)
    chatModel.source.$modelParameters
      .map { $0.$numberOfTokens }
      .switchToLatest()
      .assign(to: &$numberOfTokens)
    chatModel.source.$modelParameters
      .map { $0.$topP }
      .switchToLatest()
      .assign(to: &$topP)
    chatModel.source.$modelParameters
      .map { $0.$topK }
      .switchToLatest()
      .assign(to: &$topK)
    chatModel.source.$modelParameters
      .map { $0.$temperature }
      .switchToLatest()
      .assign(to: &$temperature)
    chatModel.source.$modelParameters
      .map { $0.$batchSize }
      .switchToLatest()
      .assign(to: &$batchSize)
    chatModel.source.$modelParameters
      .map { $0.$lastNTokensToPenalize }
      .switchToLatest()
      .assign(to: &$lastNTokensToPenalize)
    chatModel.source.$modelParameters
      .map { $0.$repeatPenalty }
      .switchToLatest()
      .assign(to: &$repeatPenalty)
  }

  func clearMessages() {
    Task.init {
      await chatModel.clearMessages()
    }
  }

  func showInfo() {
    SettingsWindowPresenter.shared.present(deeplinkingTo: .sources(sourceId: chatModel.source.id, sourcesTab: .properties))
  }

  func configureParameters() {
    SettingsWindowPresenter.shared.present(deeplinkingTo: .sources(sourceId: chatModel.source.id, sourcesTab: .parameters))
  }

  func loadModelStats() {
    context = .loading
    contextTokenCount = .loading

    Task.init {
      do {
        let context = try await chatModel.loadContext()
        await MainActor.run {
          self.context = context?.contextString.flatMap { .value($0) } ?? .none
          let tokenCount = context?.tokens?.count
          self.contextTokenCount = tokenCount.map { .value($0) } ?? .none
        }
      } catch {
        self.context = .unknown
        self.contextTokenCount = .unknown
      }
    }
  }
}
