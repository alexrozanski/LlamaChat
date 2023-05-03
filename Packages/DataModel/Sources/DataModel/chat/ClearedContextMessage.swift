//
//  ClearedContextMessage.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation

public class ClearedContextMessage: Message {
  public let id = UUID()
  public var messageType: MessageType { return .clearedContext }
  public var content: String { return "" }
  public var sender: Sender { return .other }
  public let sendDate: Date
  public var isError: Bool { return false }

  public init(sendDate: Date) {
    self.sendDate = sendDate
  }
}
