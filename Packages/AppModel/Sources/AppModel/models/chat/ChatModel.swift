//
//  ChatModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine
import DataModel
import ModelCompatibility
import SQLite

public class ChatModel: ObservableObject {
  enum Error: Swift.Error {
    case cannotCreateSession
  }

  public typealias ModelParametersViewModelBuilder = (AnyModelParameters?, ChatModel) -> ModelParametersViewModel?

  public let source: ChatSource
  public let messagesModel: MessagesModel

  public enum ReplyState {
    case none
    case waitingToRespond
    case responding
  }

  private var session: LLMSession?

  @Published public private(set) var messages: [Message]
  @Published public private(set) var replyState: ReplyState = .none

  @Published public private(set) var lastSessionContext: LLMSessionContext? = nil {
    didSet {
      guard let lastSessionContext else {
        canClearContext = false
        return
      }
      canClearContext = lastSessionContext.contextString != nil && lastSessionContext.tokens != nil
    }
  }
  @Published public private(set) var canClearContext: Bool = false

  public private(set) var parametersViewModel = CurrentValueSubject<ModelParametersViewModel?, Never>(nil)

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
        do {
          try await predictResponse(to: message.content)
        } catch {
          print("Can't predict response:", error)
        }
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
    do {
      if session != nil {
        _ = try makeAndStoreNewSession()
      }
    } catch {
      print("Error clearing context: can't create new session")
    }

    lastSessionContext = nil
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

  public func loadContext() async throws -> LLMSessionContext? {
    let sessionContext = try await getReadySession().currentContext()
    await MainActor.run {
      self.lastSessionContext = sessionContext
    }
    return sessionContext
  }

  // MARK: - Private

  @MainActor
  private func makeAndStoreNewSession() throws -> LLMSession {
    let numThreads = UInt(AppSettingsModel.shared.numThreads)
    guard let newSession = makeSession(for: source, numThreads: numThreads, delegate: self) else {
      throw Error.cannotCreateSession
    }

    self.session = newSession
    self.lastSessionContext = nil

    return newSession
  }

  private func getReadySession() async throws -> LLMSession {
    guard let session = session else {
      return try await makeAndStoreNewSession()
    }

    if session.state.isError {
      return try await makeAndStoreNewSession()
    }

    return session
  }

  private func predictResponse(to content: String) async throws {
    let message = GeneratedMessage(sender: .other, sendDate: Date())

    await MainActor.run {
      replyState = .waitingToRespond
      messages.append(message)
    }

    var hasReceivedTokens = false
    let session = try await getReadySession()
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
      stateChangeHandler: { predictionState in
        switch predictionState {
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
          message.update(contents: predictionErrorMessage(from: error))
          self.messagesModel.append(message: message, in: self.source)
          self.replyState = .none
        }
      })
    message.cancellationHandler = { cancellable.cancel() }
  }
}

extension ChatModel: LLMSessionDelegate {
  public func llmSession(_ session: LLMSession, stateDidChange state: LLMSessionState) {}

  public func llmSession(_ session: LLMSession, didUpdateSessionContext sessionContext: LLMSessionContext) {
    lastSessionContext = sessionContext
  }
}
