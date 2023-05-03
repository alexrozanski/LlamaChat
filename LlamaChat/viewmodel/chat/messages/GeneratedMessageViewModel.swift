//
//  GeneratedMessageViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import AppKit
import Foundation
import Combine
import DataModel

class GeneratedMessageViewModel: ObservableObject, MessageViewModel {
  var id: UUID { message.id }

  private let message: GeneratedMessage

  @Published var content: String
  @Published var state: MessageGenerationState
  @Published var isError: Bool = false

  var sender: Sender { return message.sender }

  private var subscriptions = Set<AnyCancellable>()

  let canCopyContents = CurrentValueSubject<Bool, Never>(false)

  init(message: GeneratedMessage) {
    self.message = message
    content = message.content
    state = message.state

    message.contentDidChange.sink { [weak self] in
      self?.content = message.content
    }.store(in: &subscriptions)
    message.$state.sink { [weak self] newState in
      self?.state = newState

      switch newState {
      case .none, .error, .generating, .waiting:
        self?.canCopyContents.send(false)
      case .cancelled, .finished:
        self?.canCopyContents.send(true)
      }
    }.store(in: &subscriptions)
    message.$isError.sink { [weak self] newIsError in
      self?.isError = newIsError
    }.store(in: &subscriptions)

    canCopyContents.sink { [weak self] _ in self?.objectWillChange.send() }.store(in: &subscriptions)
  }

  func stopGeneratingContent() {
    message.cancelGeneration()
  }

  func copyContents() {
    switch state {
    case .none, .error, .generating, .waiting:
      break
    case .cancelled, .finished:
      NSPasteboard.general.prepareForNewContents()
      NSPasteboard.general.setString(content, forType: .string)
    }
  }
}
