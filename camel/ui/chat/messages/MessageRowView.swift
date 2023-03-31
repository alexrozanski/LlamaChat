//
//  MessageRowView.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import SwiftUI

struct MessageRowView<MessageView>: View where MessageView: View {
  typealias MessageBuilder = () -> MessageView

  let sender: Sender
  let maxWidth: Double?
  @ViewBuilder let messageBuilder: MessageBuilder

  var body: some View {
    HStack(spacing: 0) {
      if sender.isMe {
        Spacer()
      }
      messageBuilder()
      .frame(maxWidth: maxWidth ?? .infinity, alignment: sender.isMe ? .trailing : .leading)
      if !sender.isMe {
        Spacer()
      }
    }
  }
}
