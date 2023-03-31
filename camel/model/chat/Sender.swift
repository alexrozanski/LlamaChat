//
//  Sender.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import Foundation

enum Sender {
  case me
  case other

  var isMe: Bool {
    switch self {
    case .me: return true
    case .other: return false
    }
  }
}
