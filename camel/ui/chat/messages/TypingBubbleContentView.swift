//
//  TypingBubbleView.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import SwiftUI

struct CircleView: View {
  @State var opacity: Double = 0.2

  let startDelay: Double

  var body: some View {
    Circle()
      .fill(.black)
      .frame(width: 10, height: 10)
      .opacity(opacity)
      .onAppear {
        withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true).delay(startDelay)) {
          opacity = 0.4
        }
      }
  }
}

struct TypingBubbleContentView: View {
  @State var scale = Double(1.0)

  var body: some View {
    HStack(spacing: 2) {
      CircleView(startDelay: 0)
      CircleView(startDelay: 0.33)
      CircleView(startDelay: 0.66)
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 12)
//    .background(.gray.opacity(0.2))
    .cornerRadius(20)
//    .scaleEffect(scale)
//    .onAppear {
//      withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
//        scale = 0.96
//      }
//    }
  }
}
