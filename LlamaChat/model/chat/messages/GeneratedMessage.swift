//
//  GeneratedMessage.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation
import Combine

class GeneratedMessage: ObservableObject, Message {
  typealias CancellationHandler = () -> Void

  var messageType: MessageType { return .message }

  let id = UUID()
  private(set) var content: String = "" {
    didSet {
      contentDidChange.send()
    }
  }
  let contentDidChange = PassthroughSubject<Void, Never>()
  let sender: Sender
  let sendDate: Date

  @Published var isError = false

  @Published private(set) var state: MessageGenerationState = .none {
    didSet {
      isError = state.isError
    }
  }

  var cancellationHandler: CancellationHandler?

  init(sender: Sender, sendDate: Date) {
    self.sender = sender
    self.sendDate = sendDate
  }

  func update(contents: String) {
    content = contents
  }

  func append(contents: String) {
    if content.isEmpty {
      content = contents.trimmingCharactersInCharacterSetFromPrefix(.whitespacesAndNewlines)
    } else {
      content += contents
    }
  }

  func updateState(_ state: MessageGenerationState) {
    self.state = state
  }

  func cancelGeneration() {
    cancellationHandler?()
  }
}

private extension String {
  func trimmingCharactersInCharacterSetFromPrefix(_ characterSet: CharacterSet) -> String {
    return String(trimmingPrefix(while: { character in character.unicodeScalars.allSatisfy { scalar in characterSet.contains(scalar) } }))
  }
}
