//
//  StreamedMessage.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation
import Combine

class StreamedMessage: Message {
  let id = UUID()
  private(set) var content: String = "" {
    didSet {
      contentDidChange.send()
    }
  }
  let contentDidChange = PassthroughSubject<Void, Never>()
  let sender: Sender

  init(sender: Sender) {
    self.sender = sender
  }

  func append(content: String) {
    self.content += content
  }
}
