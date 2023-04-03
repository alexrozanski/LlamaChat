//
//  ModelContextContentViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation
import Combine

class ModelContextContentViewModel: ObservableObject {
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

  @Published var hasSource: Bool = false
  @Published private(set) var context: String? = ""

  private var contextCancellable: AnyCancellable?

  init(chatSourceId: ChatSource.ID?) {
    self.chatSourceId = chatSourceId
  }

  private func updateState() {
    guard let chatSources, let chatModels else {
      contextCancellable = nil
      context = nil
      return
    }

    guard let chatSource = chatSourceId.flatMap({ chatSources.source(for: $0) }) else {
      contextCancellable = nil
      context = nil
      return
    }

    let chatModel = chatModels.chatModel(for: chatSource)
    context = chatModel.lastChatContext?.contextString

    contextCancellable = chatModel.$lastChatContext.receive(on: DispatchQueue.main).sink(receiveValue: { newContext in
      self.context = newContext?.contextString
    })

    self.chatSource = chatSource
    self.chatModel = chatModel
  }
}
