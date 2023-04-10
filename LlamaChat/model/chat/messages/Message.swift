//
//  Message.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation
import Combine

enum MessageType: Int {
  case message = 1
  // Implement this as a message just to make this easier
  case clearedContext = 2

  var isClearedContext: Bool {
    switch self {
    case .message:
      return false
    case .clearedContext:
      return true
    }
  }
}

protocol Message {
  var id: UUID { get }
  var messageType: MessageType { get }
  var sender: Sender { get }
  var content: String { get }
  var sendDate: Date { get }
  var isError: Bool { get }
}
