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

  let id = UUID()
  private(set) var content: String = "" {
    didSet {
      contentDidChange.send()
    }
  }
  let contentDidChange = PassthroughSubject<Void, Never>()
  let sender: Sender

  @Published private(set) var state: MessageGenerationState = .none

  var cancellationHandler: CancellationHandler?

  init(sender: Sender) {
    self.sender = sender
  }

  func append(contents: String) {
    if self.content.isEmpty {
      self.content = contents.trimmingCharactersInCharacterSetFromPrefix(.whitespacesAndNewlines)
    } else {
      self.content += contents
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
