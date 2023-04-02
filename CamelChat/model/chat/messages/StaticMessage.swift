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
  let sendDate: Date

  init(content: String, sender: Sender, sendDate: Date) {
    self.content = content
    self.sender = sender
    self.sendDate = sendDate
  }
}
