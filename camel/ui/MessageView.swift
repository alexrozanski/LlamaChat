//
//  MessageView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessageView: View {
  var message: Message

  var body: some View {
    Text(message.content)
      .padding(8)
      .background(message.isMe ? .blue : .gray.opacity(0.2))
      .foregroundColor(message.isMe ? .white : .black)
      .cornerRadius(8)
      .frame(maxWidth: .infinity, alignment: message.isMe ? .trailing : .leading)
  }
}

extension Message {
  var isMe: Bool {
    switch sender {
    case .me: return true
    case .other: return false
    }
  }
}
