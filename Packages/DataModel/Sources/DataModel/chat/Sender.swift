//
//  Sender.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation

public enum Sender {
  case me
  case other

  public var isMe: Bool {
    switch self {
    case .me: return true
    case .other: return false
    }
  }
}
