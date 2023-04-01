//
//  StaticMessage.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation
import Combine

class StaticMessage: Message {
  let id = UUID()
  let content: String
  let sender: Sender

  init(content: String, sender: Sender) {
    self.content = content
    self.sender = sender
  }
}
