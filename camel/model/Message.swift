//
//  Message.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import Foundation

struct Message {
  enum Sender {
    case me
    case other
  }

  let id = UUID()
  let content: String
  let sender: Sender
}
