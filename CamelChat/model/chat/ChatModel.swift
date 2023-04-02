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

class ChatModel: ObservableObject {
  struct ChatContext {
    let contextString: String?
    let tokens: [Int64]?
  }

  let source: ChatSource
  let messagesModel: MessagesModel

  private lazy var session: Session = {
    switch source.type {
    case .llama:
      return Inference(config: .default).makeLlamaSession(with: source.modelURL, config: LlamaSessionConfig(numTokens: 512), stateChangeHandler: { _ in })
    case .alpaca:
      return Inference(config: .default).makeAlpacaSession(with: source.modelURL, config: AlpacaSessionConfig(numTokens: 512), stateChangeHandler: { _ in })
    }
  }()

  enum ReplyState {
    case none
    case waitingToRespond
    case responding
  }  

  @Published var messages: [Message]
  @Published var replyState: ReplyState = .none

  private var currentPredictionCancellable: PredictionCancellable?

  init(source: ChatSource, messagesModel: MessagesModel) {
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

  func loadContext() async -> ChatContext {
    let sessionContext = await session.currentContext()
    return ChatContext(contextString: sessionContext.contextString, tokens: sessionContext.tokens)
  }

  private func predictResponse(to content: String) {
    replyState = .waitingToRespond

    let message = GeneratedMessage(sender: .other, sendDate: Date())
    messages.append(message)

    var hasReceivedTokens = false
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
          self.replyState = .none
        }
      },
      handlerQueue: .main
    )

    message.cancellationHandler = { cancellable.cancel() }
  }
}
