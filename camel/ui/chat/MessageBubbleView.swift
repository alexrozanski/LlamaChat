//
//  MessageBubbleView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessageBubbleView: View {
  var viewModel: MessageViewModel

  var body: some View {
    Text(viewModel.content)
      .padding(8)
      .background(viewModel.isMe ? .blue : .gray.opacity(0.2))
      .foregroundColor(viewModel.isMe ? .white : .black)
      .cornerRadius(8)
      .frame(maxWidth: .infinity, alignment: viewModel.isMe ? .trailing : .leading)
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
