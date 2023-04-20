//
//  MessageBubbleView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MessageBubbleView<Content>: View where Content: View {
  @State private var scale = Double(1.0)

  enum Style {
    case regular
    case typing
  }

  typealias ContentBuilder = () -> Content

  let sender: Sender
  let style: Style
  let isError: Bool
  let availableWidth: Double?
  @ViewBuilder var content: ContentBuilder

  var padding: Double {
    switch style {
    case .regular: return 8
    case .typing: return 0
    }
  }

  var body: some View {
    HStack {
      if sender.isMe {
        Spacer()
      }
      content()
        .padding(padding)
        .background(backgroundColor)
        .foregroundColor(textColor)
        .cornerRadius(15)
        .scaleEffect(scale)
        .onAppear {
          updateScaleAnimation(with: style)
        }
        .onChange(of: style) { newStyle in
          updateScaleAnimation(with: newStyle)
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: availableWidth.map { $0 * 0.8 } ?? .infinity, alignment: sender.isMe ? .trailing : .leading)
      if !sender.isMe {
        Spacer()
      }
    }
  }

  private var backgroundColor: Color {
    if isError {
      return .red
    }
    return sender.isMe ? .blue : .gray.opacity(0.2)
  }

  private var textColor: Color {
    if isError {
      return .white
    }
    return sender.isMe ? .white : .primary
  }

  private func updateScaleAnimation(with style: Style) {
    var transaction = Transaction()
    transaction.disablesAnimations = true
    withTransaction(transaction) {
      guard style == .typing else {
        scale = 1
        return
      }

      withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
        scale = 0.96
      }
    }
  }
}
