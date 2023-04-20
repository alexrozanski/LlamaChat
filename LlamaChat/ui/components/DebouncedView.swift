//
//  DebouncedView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct DebouncedView<Content>: View where Content: View {
  typealias ContentBuilder = () -> Content

  @State private var showView = false

  let isVisible: Bool
  let delay: Double
  var animation: Animation?

  let contentBuilder: ContentBuilder
  init(isVisible: Bool, delay: Double, animation: Animation? = nil, contentBuilder: @escaping ContentBuilder) {
    self.isVisible = isVisible
    self.delay = delay
    self.animation = animation
    self.contentBuilder = contentBuilder
  }

  var body: some View {
    VStack {
      if showView {
        contentBuilder()
      }
    }
    .animation(animation, value: showView)
    .onChange(of: isVisible) { newIsVisible in
      if newIsVisible {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          self.showView = true
        }
      } else {
        showView = false
      }
    }
    .onAppear {
      if isVisible {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
          self.showView = true
        }
      }
    }
  }
}
