//
//  ChatModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine
import CameLLM
import CameLLMLlama
import DataModel
import ModelCompatibility
import SQLite

public class ChatModel: ObservableObject {
  public typealias ModelParametersViewModelBuilder = (AnyModelParameters?, ChatModel) -> ModelParametersViewModel?

  public class ChatContext {
    public struct Token {
      public let value: Int32
      public let string: String
    }

    public var contextString: String? {
      return sessionContext.contextString
    }

    public private(set) lazy var tokens: [Token]? = {
      return sessionContext.tokens?.map { Token(value: $0.value, string: $0.string) }
    }()

    private let sessionContext: SessionContext

    init(sessionContext: SessionContext) {
      self.sessionContext = sessionContext
    }
  }

  public let source: ChatSource
  public let messagesModel: MessagesModel

  public enum ReplyState {
    case none
    case waitingToRespond
    case responding
  }

  private var session: (any Session<LlamaSessionState, LlamaPredictionState>)?

  @Published public private(set) var messages: [Message]
  @Published public private(set) var replyState: ReplyState = .none

  @Published public private(set) var lastChatContext: ChatContext? = nil {
    didSet {
      guard let lastChatContext else {
        canClearContext = false
        return
      }
      canClearContext = lastChatContext.contextString != nil && lastChatContext.tokens != nil
    }
  }
  @Published public private(set) var canClearContext: Bool = false

  public private(set) var parametersViewModel = CurrentValueSubject<ModelParametersViewModel?, Never>(nil)

  private var currentPredictionCancellable: PredictionCancellable?
  private var subscriptions = Set<AnyCancellable>()

  init(
    source: ChatSource,
    messagesModel: MessagesModel,
    modelParametersViewModelBuilder: @escaping ModelParametersViewModelBuilder
  ) {
    self.source = source
    self.messagesModel = messagesModel
    messages = messagesModel.loadMessages(from: source)

    // By definition we clear the context on each launch because we don't persist session state.
    insertClearedContextMessageIfNeeded()

    AppSettingsModel.shared.$numThreads
      .combineLatest(source.modelParametersDidChange)
      .debounce(for: .zero, scheduler: RunLoop.current)
      .sink { _ in
        Task.init {
          await self.clearContext(insertClearedContextMessage: true)
        }
      }.store(in: &subscriptions)

    source.$modelParameters
      .map { [weak self] parameters -> ModelParametersViewModel? in
        guard let self else { return nil }
        return modelParametersViewModelBuilder(parameters, self)
      }
      .sink { [weak self] viewModel in
        self?.parametersViewModel.send(viewModel)
        self?.objectWillChange.send()
      }
      .store(in: &subscriptions)
  }

  public func send(message: StaticMessage) {
    messages.append(message)
    messagesModel.append(message: message, in: source)

    if (message.sender.isMe) {
      Task.init {
        await predictResponse(to: message.content)
      }
    }
  }

  // MARK: - Messages

  public func clearMessages() async {
    await MainActor.run {
      messagesModel.clearMessages(for: source)
      messages = []
    }
    await clearContext(insertClearedContextMessage: false)
  }

  // MARK: - Context

  public func clearContext() {
    Task.init {
      await clearContext(insertClearedContextMessage: true)
    }
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

  public func loadContext() async throws -> ChatContext? {
    let sessionContext = try await getReadySession().sessionContextProviding.provider?.currentContext()
    let context = sessionContext.map { ChatModel.ChatContext(sessionContext: $0) }
    await MainActor.run {
      self.lastChatContext = context
    }
    return context
  }

  // MARK: - Private

  @MainActor
  private func makeAndStoreNewSession() -> any Session<LlamaSessionState, LlamaPredictionState> {
    let numThreads = UInt(AppSettingsModel.shared.numThreads)
    let newSession = makeSession(for: source, numThreads: numThreads)

    newSession.sessionContextProviding.provider?.updatedContextHandler = { [weak self] newSessionContext in
      self?.lastChatContext = ChatModel.ChatContext(sessionContext: newSessionContext)
    }

    self.session = newSession
    self.lastChatContext = nil

    return newSession
  }

  private func getReadySession() async -> any Session<LlamaSessionState, LlamaPredictionState> {
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

fileprivate extension LlamaSessionState {
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
  let nsError = error as NSError
  if nsError.domain == CameLLMError.Domain {
    if let code = CameLLMError.Code(rawValue: nsError.code) {
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
