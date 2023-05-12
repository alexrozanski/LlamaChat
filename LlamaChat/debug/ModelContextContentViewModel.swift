//
//  ModelContextContentViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation
import Combine
import AppModel
import DataModel
import ModelCompatibility

class ModelContextContentViewModel: ObservableObject {
  enum Context {
    case empty
    case context(string: String, tokens: [LLMSessionContext.Token])

    var isEmpty: Bool {
      switch self {
      case .empty: return true
      case .context: return false
      }
    }
  }

  enum ContextPresentation: String, Identifiable, CaseIterable {
    case text
    case tokens
    case both

    var id: String {
      return rawValue
    }
  }

  let chatSourceId: ChatSource.ID?

  private var chatSource: ChatSource? {
    didSet {
      hasSource = chatSource != nil
    }
  }
  private var chatModel: ChatModel?

  var chatSourcesModel: ChatSourcesModel? {
    didSet {
      updateState()
    }
  }
  var chatModels: ChatModels? {
    didSet {
      updateState()
    }
  }

  @Published private var sessionContext: LLMSessionContext?
  @Published private(set) var contextPresentation: ContextPresentation = .text

  @Published private(set) var hasSource = false
  @Published private(set) var context: Context = .empty

  init(chatSourceId: ChatSource.ID?) {
    self.chatSourceId = chatSourceId

    $sessionContext
      .map { sessionContext in
        guard let sessionContext, let contextString = sessionContext.contextString, let tokens = sessionContext.tokens else {
          return .empty
        }
        return .context(string: contextString, tokens: tokens)
      }
      .assign(to: &$context)
  }

  func updateContextPresentation(_ contextPresentation: ContextPresentation) {
    self.contextPresentation = contextPresentation
  }

  private func updateState() {
    guard let chatSourcesModel, let chatModels else {
      sessionContext = nil
      return
    }

    guard let chatSource = chatSourceId.flatMap({ chatSourcesModel.source(for: $0) }) else {
      sessionContext = nil
      return
    }

    let chatModel = chatModels.chatModel(for: chatSource)
    sessionContext = chatModel.lastSessionContext

    chatModel.$lastSessionContext
      .receive(on: DispatchQueue.main)
      .assign(to: &$sessionContext)

    self.chatSource = chatSource
    self.chatModel = chatModel
  }
}
