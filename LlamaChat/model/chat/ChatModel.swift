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

// MARK: -

class ChatModel: ObservableObject {
  class ChatContext {
    struct Token {
      let value: Int32
      let string: String
    }

    var contextString: String? {
      return sessionContext.contextString
    }

    private(set) lazy var tokens: [Token]? = {
      return sessionContext.tokens?.map { Token(value: $0.value, string: $0.string) }
    }()

    private let sessionContext: SessionContext

    init(sessionContext: SessionContext) {
      self.sessionContext = sessionContext
    }
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

  @Published private(set) var lastChatContext: ChatContext? = nil {
    didSet {
      guard let lastChatContext else {
        canClearContext = false
        return
      }
      canClearContext = lastChatContext.contextString != nil && lastChatContext.tokens != nil
    }
  }
  @Published private(set) var canClearContext: Bool = false

  private var currentPredictionCancellable: PredictionCancellable?
  private var subscriptions = Set<AnyCancellable>()

  fileprivate init(source: ChatSource, messagesModel: MessagesModel) {
    self.source = source
    self.messagesModel = messagesModel
    messages = messagesModel.loadMessages(from: source)

    // By definition we clear the context on each launch because we don't persist session state.
    insertClearedContextMessageIfNeeded()

    AppSettings.shared.$numThreads
      .receive(on: DispatchQueue.main).sink { _ in
        Task.init {
          await self.clearContext(insertClearedContextMessage: true)
        }
      }.store(in: &subscriptions)
  }

  func send(message: StaticMessage) {
    messages.append(message)
    messagesModel.append(message: message, in: source)

    if (message.sender.isMe) {
      Task.init {
        await predictResponse(to: message.content)
      }
    }
  }

  // MARK: - Messages

  func clearMessages() async {
    await MainActor.run {
      messagesModel.clearMessages(for: source)
      messages = []
    }
    await clearContext(insertClearedContextMessage: false)
  }

  // MARK: - Context

  func clearContext() async {
    await clearContext(insertClearedContextMessage: true)
  }

  // Creates a fresh session.
  // Inserts a 'cleared context' message if needed (i.e. the last message also wasn't
  // a 'cleared context' message).

  @MainActor
  private func clearContext(insertClearedContextMessage: Bool) async {
    if session != nil {
      _ = makeAndStoreNewSession()
    }

    lastChatContext = nil
    if insertClearedContextMessage {
      insertClearedContextMessageIfNeeded()
    }
  }

  private func insertClearedContextMessageIfNeeded() {
    if messages.count > 0 && !(messages.last?.messageType.isClearedContext ?? false) {
      let clearedContextMessage = ClearedContextMessage(sendDate: Date())
      messages.append(clearedContextMessage)
      messagesModel.append(message: clearedContextMessage, in: source)
    }
  }

  func loadContext() async throws -> ChatContext {
    let sessionContext = try await getReadySession().currentContext()
    let context = ChatModel.ChatContext(sessionContext: sessionContext)
    await MainActor.run {
      self.lastChatContext = context
    }
    return context
  }

  // MARK: - Private

  @MainActor
  private func makeAndStoreNewSession() -> Session {
    var newSession: Session
    let numThreads = UInt(AppSettings.shared.numThreads)

    switch source.type {
    case .llama:
      newSession = SessionManager().makeLlamaSession(
        with: source.modelURL,
        config: LlamaSessionConfig(numThreads: numThreads, numTokens: 512)
      )
    case .alpaca:
      newSession = SessionManager().makeAlpacaSession(
        with: source.modelURL,
        config: AlpacaSessionConfig(numThreads: numThreads, numTokens: 512)
      )
    case .gpt4All:
      newSession = SessionManager().makeGPT4AllSession(
        with: source.modelURL,
        config: GPT4AllSessionConfig(numThreads: numThreads, numTokens: 512)
      )
    }

    newSession.updatedContextHandler = { [weak self] newSessionContext in
      self?.lastChatContext = ChatModel.ChatContext(sessionContext: newSessionContext)
    }

    self.session = newSession
    self.lastChatContext = nil

    return newSession
  }

  private func getReadySession() async -> Session {
    guard let session = session else {
      return await makeAndStoreNewSession()
    }

    if session.state.isError {
      return await makeAndStoreNewSession()
    }

    return session
  }

  private func predictResponse(to content: String) async {
    let message = GeneratedMessage(sender: .other, sendDate: Date())

    await MainActor.run {
      replyState = .waitingToRespond
      messages.append(message)
    }

    var hasReceivedTokens = false
    let session = await getReadySession()
    let cancellable = session.predict(
      with: content,
      tokenHandler: { token in
        if !hasReceivedTokens {
          message.updateState(.generating)
          self.replyState = .responding
          hasReceivedTokens = true
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

private func errorText(from error: Error) -> String {
  print(error)

  let nsError = error as NSError
  if nsError.domain == LlamaError.Domain {
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
