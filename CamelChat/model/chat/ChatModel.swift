//
//  ChatModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine
import llama

class ChatModel: ObservableObject {
  private let source: ChatSource

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

  @Published var messages = [Message]()
  @Published var replyState: ReplyState = .none

  private var currentPredictionCancellable: PredictionCancellable?

  init(source: ChatSource) {
    self.source = source
  }

  func send(message: StaticMessage) {
    messages.append(message)

    if (message.sender.isMe) {
      predictResponse(to: message.content)
    }
  }

  private func predictResponse(to content: String) {
    replyState = .waitingToRespond

    let message = GeneratedMessage(sender: .other)
    messages.append(message)

    let cancellable = session.predict(
      with: content,
      tokenHandler: { token in
        message.append(contents: token)
      },
      stateChangeHandler: { newState in
        switch newState {
        case .notStarted:
          message.updateState(.waiting)
        case .predicting:
          message.updateState(.generating)
          self.replyState = .responding
        case .cancelled:
          message.updateState(.cancelled)
          self.replyState = .none
        case .finished:
          message.updateState(.finished)
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
