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

  @Published var messages = [Message]()

  init(source: ChatSource) {
    self.source = source
  }

  func append(message: StaticMessage) {
    messages.append(message)

    if (message.isMe) {
      let newMessage = StreamedMessage(sender: .other)
      messages.append(newMessage)
      Task {
        await predictResponse(to: message.content, with: newMessage)
      }
    }
  }

  @MainActor private func predictResponse(to content: String, with message: StreamedMessage) async {
    do {
      for try await token in session.predict(with: content) {
        message.append(contents: token)
      }
    } catch {
      print(error)
    }
  }
}
