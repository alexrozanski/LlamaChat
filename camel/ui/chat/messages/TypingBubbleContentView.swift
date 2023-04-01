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
      .frame(width: 8, height: 8)
      .opacity(opacity)
      .onAppear {
        withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true).delay(startDelay)) {
          opacity = 0.4
        }
      }
  }
}

struct TypingBubbleContentView: View {
  var body: some View {
    HStack(spacing: 2) {
      CircleView(startDelay: 0)
      CircleView(startDelay: 0.33)
      CircleView(startDelay: 0.66)
    }
    .padding(.vertical, 10)
    .padding(.horizontal, 10)
  }
}
