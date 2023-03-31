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
    return Inference(config: .default).makeLlamaSession(with: source.modelURL, config: LlamaSessionConfig(numTokens: 512), stateChangeHandler: { state in
      print("Updated state: ", state)
    })
  }()

  enum ReplyState {
    case none
    case waitingToRespond
    case responding
  }

  @Published var messages = [Message]()
  @Published var replyState: ReplyState = .none

  init(source: ChatSource) {
    self.source = source
  }

  func append(message: StaticMessage) {
    messages.append(message)

    if (message.isMe) {
      let newMessage = StreamedMessage(sender: .other)
      messages.append(newMessage)
      predictResponse(to: message.content, with: newMessage)
    }
  }

  private func predictResponse(to content: String, with message: StreamedMessage) {
    do {
      replyState = .waitingToRespond
      _ = session.predict(with: content, receiveToken: { token in
        self.replyState = .responding
        message.append(contents: token)
      }, on: .main)
    }
  }
}
