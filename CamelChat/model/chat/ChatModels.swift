//
//  ChatModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine
import llama
import SQLite

class ChatModels: ObservableObject {
  let messagesModel: MessagesModel

  private var models: [ChatModel] = []

  init(messagesModel: MessagesModel) {
    self.messagesModel = messagesModel
  }

  func chatModel(for source: ChatSource) -> ChatModel {
    if let existingModel = models.first(where: { $0.source.id == source.id }) {
      return existingModel
    }

    let newModel = ChatModel(source: source, messagesModel: messagesModel)
    models.append(newModel)
    return newModel
  }
}

class ChatModel: ObservableObject {
  struct ChatContext {
    let contextString: String?
    let tokens: [Int64]?
  }

  let source: ChatSource
  let messagesModel: MessagesModel

  enum ReplyState {
    case none
    case waitingToRespond
    case responding
  }

  private var session: Session?

  @Published private(set) var messages: [Message]
  @Published private(set) var replyState: ReplyState = .none

  @Published private(set) var lastChatContext: ChatContext? = nil
  @Published private(set) var canClearContext: Bool = false

  private var currentPredictionCancellable: PredictionCancellable?

  fileprivate init(source: ChatSource, messagesModel: MessagesModel) {
    self.source = source
    self.messagesModel = messagesModel
    messages = messagesModel.loadMessages(from: source)
  }

  func send(message: StaticMessage) {
    messages.append(message)
    messagesModel.append(message: message, in: source)

    if (message.sender.isMe) {
      predictResponse(to: message.content)
    }
  }

  func clearContext() {
    _ = makeAndStoreNewSession()
  }

  func loadContext() async throws -> ChatContext {
    let sessionContext = try await getReadySession().currentContext()
    let context = ChatContext(contextString: sessionContext.contextString, tokens: sessionContext.tokens)
    self.lastChatContext = context
    return context
  }

  private func makeAndStoreNewSession() -> Session {
    let newSession = makeSession(for: self.source)
    self.session = newSession
    return newSession
  }

  private func getReadySession() -> Session {
    guard let session = session else {
      return makeAndStoreNewSession()
    }

    if session.state.isError {
      return makeAndStoreNewSession()
    }

    return session
  }

  private func predictResponse(to content: String) {
    replyState = .waitingToRespond

    let message = GeneratedMessage(sender: .other, sendDate: Date())
    messages.append(message)

    var hasReceivedTokens = false
    let cancellable = getReadySession().predict(
      with: content,
      tokenHandler: { token in
        if !hasReceivedTokens {
          message.updateState(.generating)
          self.replyState = .responding
          hasReceivedTokens = true
          self.canClearContext = true
        }

        message.append(contents: token)
      },
      stateChangeHandler: { newState in
        switch newState {
        case .notStarted:
          message.updateState(.waiting)
        case .predicting:
          // Handle this in the tokenHandler so that we are marked as waiting until
          // we start actually receving tokens.
          break
        case .cancelled:
          message.updateState(.cancelled)
          self.messagesModel.append(message: message, in: self.source)
          self.replyState = .none
        case .finished:
          message.updateState(.finished)
          self.messagesModel.append(message: message, in: self.source)
          self.replyState = .none
        case .error(let error):
          message.updateState(.error(error))
          message.update(contents: errorText(from: error))
          self.messagesModel.append(message: message, in: self.source)
          self.replyState = .none
        }
      },
      handlerQueue: .main
    )

    message.cancellationHandler = { cancellable.cancel() }
  }
}

fileprivate extension SessionState {
  var isError: Bool {
    switch self {
    case .notStarted, .loadingModel, .predicting, .readyToPredict:
      return false
    case .error:
      return true
    }
  }
}

private func makeSession(for source: ChatSource) -> Session {
  switch source.type {
  case .llama:
    return Inference(config: .default).makeLlamaSession(
      with: source.modelURL,
      config: LlamaSessionConfig(numTokens: 512),
      stateChangeHandler: { _ in }
    )
  case .alpaca:
    return Inference(config: .default).makeAlpacaSession(
      with: source.modelURL,
      config: AlpacaSessionConfig(numTokens: 512),
      stateChangeHandler: { _ in }
    )
  case .gpt4All:
    return Inference(config: .default).makeGPT4AllSession(
      with: source.modelURL,
      config: GPT4AllSessionConfig.default,
      stateChangeHandler: { _ in }
    )
  }
}

private func errorText(from error: Error) -> String {
  print(error)

  let nsError = error as NSError
  if nsError.domain == LlamaError.domain {
    if let code = LlamaError.Code(rawValue: nsError.code) {
      switch code {
      case .failedToLoadModel:
        return "Failed to load model"
      case .failedToPredict:
        return "Failed to generate response"
      default:
        break
      }
    }
  }
  return "Failed to generate response"
}
