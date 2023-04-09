//
//  GeneratedMessageViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation
import Combine

class GeneratedMessageViewModel: ObservableObject, MessageViewModel {
  var id: UUID { message.id }

  private let message: GeneratedMessage

  @Published var content: String
  @Published var state: MessageGenerationState
  @Published var isError: Bool = false

  var sender: Sender { return message.sender }

  private var subscriptions = Set<AnyCancellable>()

  init(message: GeneratedMessage) {
    self.message = message
    content = message.content
    state = message.state

    message.contentDidChange.sink(receiveValue: {
      self.content = message.content
    }).store(in: &subscriptions)
    message.$state.sink(receiveValue: { newState in
      self.state = newState
    }).store(in: &subscriptions)
    message.$isError.sink(receiveValue: { newIsError in
      self.isError = newIsError
    }).store(in: &subscriptions)
  }

  func stopGeneratingContent() {
    message.cancelGeneration()
  }
}
