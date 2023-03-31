//
//  MessageBubbleView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessageBubbleView: View {
  @ObservedObject var viewModel: MessageViewModel

  let maxWidth: Double?

  @ViewBuilder var bubble: some View {
    Text(viewModel.content)
      .padding(8)
      .background(viewModel.isMe ? .blue : .gray.opacity(0.2))
      .foregroundColor(viewModel.isMe ? .white : .black)
      .cornerRadius(8)
  }

  var body: some View {
    HStack(spacing: 0) {
      if viewModel.isMe {
        Spacer()
      }
      bubble
        .frame(maxWidth: maxWidth ?? .infinity, alignment: viewModel.isMe ? .trailing : .leading)
      if !viewModel.isMe {
        Spacer()
      }
    }
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
