//
//  MessageBubbleView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI
import DataModel

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

fileprivate struct TypingBubbleShape: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: 19.305, y: 0.4839))
    path.addCurve(to: CGPoint(x: 5.94, y: 13.5483), control1: CGPoint(x: 11.92356, y: 0.4839), control2: CGPoint(x: 5.94, y: 6.333))
    path.addCurve(to: CGPoint(x: 6.82308, y: 18.2286), control1: CGPoint(x: 5.94, y: 15.1977), control2: CGPoint(x: 6.25284, y: 16.7757))
    path.addCurve(to: CGPoint(x: 4.455, y: 21.7743), control1: CGPoint(x: 5.42867, y: 18.8277), control2: CGPoint(x: 4.455, y: 20.1897))
    path.addCurve(to: CGPoint(x: 8.415, y: 25.6452), control1: CGPoint(x: 4.455, y: 23.9121), control2: CGPoint(x: 6.22809, y: 25.6452))
    path.addCurve(to: CGPoint(x: 11.52409, y: 24.1719), control1: CGPoint(x: 9.67577, y: 25.6452), control2: CGPoint(x: 10.79892, y: 25.0692))
    path.addCurve(to: CGPoint(x: 19.305, y: 26.613), control1: CGPoint(x: 13.71546, y: 25.7085), control2: CGPoint(x: 16.40232, y: 26.613))
    path.addLine(to: CGPoint(x: 36.135, y: 26.613))
    path.addCurve(to: CGPoint(x: 49.5, y: 13.5483), control1: CGPoint(x: 43.51644, y: 26.613), control2: CGPoint(x: 49.5, y: 20.7636))
    path.addCurve(to: CGPoint(x: 36.135, y: 0.4839), control1: CGPoint(x: 49.5, y: 6.333), control2: CGPoint(x: 43.51644, y: 0.4839))
    path.addLine(to: CGPoint(x: 19.305, y: 0.4839))
    path.closeSubpath()
    path.move(to: CGPoint(x: 5.445, y: 27.0969))
    path.addCurve(to: CGPoint(x: 2.97, y: 29.5161), control1: CGPoint(x: 5.445, y: 28.4328), control2: CGPoint(x: 4.33669, y: 29.5161))
    path.addCurve(to: CGPoint(x: 0.495, y: 27.0969), control1: CGPoint(x: 1.60331, y: 29.5161), control2: CGPoint(x: 0.495, y: 28.4328))
    path.addCurve(to: CGPoint(x: 2.97, y: 24.6774), control1: CGPoint(x: 0.495, y: 25.7607), control2: CGPoint(x: 1.60331, y: 24.6774))
    path.addCurve(to: CGPoint(x: 5.445, y: 27.0969), control1: CGPoint(x: 4.33669, y: 24.6774), control2: CGPoint(x: 5.445, y: 25.7607))
    path.closeSubpath()
    return path
  }
}

struct TypingBubbleView: View {
  @State private var scale = Double(1.0)

  var body: some View {
    HStack {
      TypingBubbleContentView()
        .padding(.leading, 3.5)
        .background(TypingBubbleShape().fill(Color.gray.opacity(0.2)))
        .scaleEffect(scale)
        .onAppear {
          withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
            scale = 0.96
          }
        }
        .frame(width: 49.5, height: 30)
      Spacer()
    }
  }
}

struct MessageBubbleView<Content>: View where Content: View {
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
          (
            style == .typing
            ? AnyShape(TypingBubbleShape())
            : AnyShape(BubbleShape(edge: sender.isMe ? .right : .left))
          )
          .fill(backgroundColor, style: FillStyle(eoFill: false))
        )
        .foregroundColor(textColor)
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
}
