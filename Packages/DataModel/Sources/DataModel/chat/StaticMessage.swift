//
//  StaticMessage.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation
import Combine

public class StaticMessage: Message {
  public var messageType: MessageType { return .message }
  
  public let id = UUID()
  public let content: String
  public let sender: Sender
  public let sendDate: Date
  public let isError: Bool

  public init(content: String, sender: Sender, sendDate: Date, isError: Bool) {
    self.content = content
    self.sender = sender
    self.sendDate = sendDate
    self.isError = isError
  }
}
