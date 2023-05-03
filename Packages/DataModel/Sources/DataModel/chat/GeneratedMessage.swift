//
//  GeneratedMessage.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation
import Combine

public class GeneratedMessage: ObservableObject, Message {
  public typealias CancellationHandler = () -> Void

  public var messageType: MessageType { return .message }

  public let id = UUID()
  public private(set) var content: String = "" {
    didSet {
      contentDidChange.send()
    }
  }
  public let contentDidChange = PassthroughSubject<Void, Never>()
  public let sender: Sender
  public let sendDate: Date

  @Published public var isError = false

  @Published public private(set) var state: MessageGenerationState = .none {
    didSet {
      isError = state.isError
    }
  }

  public var cancellationHandler: CancellationHandler?

  public init(sender: Sender, sendDate: Date) {
    self.sender = sender
    self.sendDate = sendDate
  }

  public func update(contents: String) {
    content = contents
  }

  public func append(contents: String) {
    if content.isEmpty {
      content = contents.trimmingCharactersInCharacterSetFromPrefix(.whitespacesAndNewlines)
    } else {
      content += contents
    }
  }

  public func updateState(_ state: MessageGenerationState) {
    self.state = state
  }

  public func cancelGeneration() {
    cancellationHandler?()
  }
}

private extension String {
  func trimmingCharactersInCharacterSetFromPrefix(_ characterSet: CharacterSet) -> String {
    return String(trimmingPrefix(while: { character in character.unicodeScalars.allSatisfy { scalar in characterSet.contains(scalar) } }))
  }
}
