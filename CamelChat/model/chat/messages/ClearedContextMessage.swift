//
//  ClearedContextMessage.swift
//  CamelChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation

class ClearedContextMessage: Message {
  let id = UUID()
  var messageType: MessageType { return .clearedContext }
  var content: String { return "" }
  var sender: Sender { return .other }
  let sendDate: Date
  var isError: Bool { return false }

  init(sendDate: Date) {
    self.sendDate = sendDate
  }
}
