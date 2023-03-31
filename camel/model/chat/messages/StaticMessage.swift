//
//  StaticMessage.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation
import Combine

struct StaticMessage: Message {
  let id = UUID()
  let content: CurrentValueSubject<String, Error>
  let sender: Sender

  init(content: String, sender: Sender) {
    self.content = CurrentValueSubject(content)
    self.sender = sender
  }
}
