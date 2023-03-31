//
//  MessageBubbleView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessageBubbleView<Content>: View where Content: View {
  typealias ContentBuilder = () -> Content

  let sender: Sender
  @ViewBuilder var content: ContentBuilder

  var body: some View {
    content()
      .padding(8)
      .background(sender.isMe ? .blue : .gray.opacity(0.2))
      .foregroundColor(sender.isMe ? .white : .black)
      .cornerRadius(8)
  }
}
