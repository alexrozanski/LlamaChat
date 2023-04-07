//
//  ComposeViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine

class ComposeViewModel: ObservableObject {
  private let chatModel: ChatModel

  @Published var text: String = ""
  @Published var allowedToCompose: Bool
  @Published var canClearContext: Bool

  private var subscriptions = Set<AnyCancellable>()

  init(chatModel: ChatModel) {
    self.chatModel = chatModel
    self.allowedToCompose = canCompose(for: chatModel.replyState)
    self.canClearContext = chatModel.canClearContext

    chatModel.$replyState.sink { replyState in
      self.allowedToCompose = canCompose(for: replyState)
    }.store(in: &subscriptions)
    chatModel.$canClearContext.sink { canClearContext in
      self.canClearContext = canClearContext
    }.store(in: &subscriptions)
  }

  func send(message: String) {
    chatModel.send(message: StaticMessage(content: message, sender: .me, sendDate: Date(), isError: false))
    text = ""
  }

  func clearContext() {
    Task.init {
      await chatModel.clearContext()
    }
  }
}

private func canCompose(for replyState: ChatModel.ReplyState) -> Bool {
  switch replyState {
  case .none:
    return true
  case .responding, .waitingToRespond:
    return false
  }
}
