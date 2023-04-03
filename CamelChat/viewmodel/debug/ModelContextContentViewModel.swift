//
//  ModelContextContentViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation
import Combine

class ModelContextContentViewModel: ObservableObject {
  enum Context {
    case empty
    case context(string: String, tokens: [ChatModel.ChatContext.Token])

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

    var label: String {
      switch self {
      case .text: return "Text"
      case .tokens: return "Tokens"
      case .both: return "Both"
      }
    }
  }

  let chatSourceId: ChatSource.ID?

  private var chatSource: ChatSource? {
    didSet {
      hasSource = chatSource != nil
    }
  }
  private var chatModel: ChatModel?

  var chatSources: ChatSources? {
    didSet {
      updateState()
    }
  }
  var chatModels: ChatModels? {
    didSet {
      updateState()
    }
  }

  private var chatContext: ChatModel.ChatContext? {
    didSet {
      guard let chatContext, let contextString = chatContext.contextString, let tokens = chatContext.tokens else {
        context = .empty
        return
      }
      context = .context(string: contextString, tokens: tokens)
    }
  }

  @Published private(set) var contextPresentation: ContextPresentation = .text

  @Published private(set) var hasSource = false
  @Published private(set) var context: Context = .empty

  private var contextCancellable: AnyCancellable?

  init(chatSourceId: ChatSource.ID?) {
    self.chatSourceId = chatSourceId
  }

  func updateContextPresentation(_ contextPresentation: ContextPresentation) {
    self.contextPresentation = contextPresentation
  }

  private func updateState() {
    guard let chatSources, let chatModels else {
      contextCancellable = nil
      chatContext = nil
      return
    }

    guard let chatSource = chatSourceId.flatMap({ chatSources.source(for: $0) }) else {
      contextCancellable = nil
      chatContext = nil
      return
    }

    let chatModel = chatModels.chatModel(for: chatSource)
    chatContext = chatModel.lastChatContext

    contextCancellable = chatModel.$lastChatContext.receive(on: DispatchQueue.main).sink(receiveValue: { newContext in
      self.chatContext = newContext
    })

    self.chatSource = chatSource
    self.chatModel = chatModel
  }
}
