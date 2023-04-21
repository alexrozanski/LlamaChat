//
//  MessageBubbleView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

private let horizontalBubblePaddingForFlick = 5.0

fileprivate struct BubbleShape: Shape {
  enum Edge {
    case left
    case right
  }

  let edge: Edge

  func path(in rect: CGRect) -> Path {
    var path = Path()

    func makePoint(x: CGFloat, y: CGFloat) -> CGPoint {
      return edge == .right ? CGPoint(x: x, y: y) : CGPoint(x: rect.width - x, y: y)
    }

    path.move(to: makePoint(x: 13.99986, y: 0))
    path.addCurve(to: makePoint(x: 0, y: 13.99995), control1: makePoint(x: 6.26787, y: 0), control2: makePoint(x: 0, y: 6.26805))
    path.addLine(to: makePoint(x: 0, y: rect.height - 13.99995))
    path.addCurve(to: makePoint(x: 13.99986, y: rect.height), control1: makePoint(x: 0, y: rect.height - 6.26805), control2: makePoint(x: 6.26787, y: rect.height))
    path.addLine(to: makePoint(x: rect.width - 19.00017, y: rect.height))
    path.addCurve(to: makePoint(x: rect.width - 10.02393, y: rect.height - 3.2553), control1: makePoint(x: rect.width - 15.58431, y: rect.height), control2: makePoint(x: rect.width - 12.45447, y: rect.height - 1.2231))
    path.addCurve(to: makePoint(x: rect.width, y: rect.height), control1: makePoint(x: rect.width - 8.00163, y: rect.height - 0.4302), control2: makePoint(x: rect.width - 4.88943, y: rect.height - 0.02115))
    path.addCurve(to: makePoint(x: rect.width - 5.00031, y: rect.height - 14.4999), control1: makePoint(x: rect.width - 4.50009, y: rect.height - 1.9998), control2: makePoint(x: rect.width - 5.00031, y: rect.height - 3.5001))
    path.addLine(to: makePoint(x: rect.width - 5.00031, y: 13.99995))
    path.addCurve(to: makePoint(x: rect.width - 19.00017, y: 0), control1: makePoint(x: rect.width - 5.00031, y: 6.26805), control2: makePoint(x: rect.width - 11.26818, y: 0))
    path.addLine(to: makePoint(x: 13.99986, y: 0))
    path.closeSubpath()
    return path
  }
}

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

  var padding: EdgeInsets {
    switch style {
    case .regular: return EdgeInsets(top: 7, leading: 9, bottom: 7, trailing: 9)
    case .typing: return EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
  }

  var body: some View {
    HStack {
      if sender.isMe {
        Spacer()
      }
      content()
        .padding(padding)
        .padding(sender.isMe ? .trailing : .leading, horizontalBubblePaddingForFlick)
        .background(
          BubbleShape(edge: sender.isMe ? .right : .left)
            .fill(backgroundColor, style: FillStyle(eoFill: false))
        )
        .foregroundColor(textColor)
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
