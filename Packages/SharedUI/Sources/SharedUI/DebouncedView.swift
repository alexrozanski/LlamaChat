//
//  DebouncedView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

public struct DebouncedView<Content>: View where Content: View {
  public typealias ContentBuilder = () -> Content

  @State private var showView = false

  var isVisible: Bool
  let delay: Double
  var animation: Animation?

  public let contentBuilder: ContentBuilder
  public init(isVisible: Bool = true, delay: Double = 0.2, animation: Animation? = nil, contentBuilder: @escaping ContentBuilder) {
    self.isVisible = isVisible
    self.delay = delay
    self.animation = animation
    self.contentBuilder = contentBuilder
  }

  public var body: some View {
    VStack {
      // Do a sanity `isVisible` check for race conditions between setting `showView` to trye in the asyncAfter() and
      // `isVisible` becoming false.
      if showView && isVisible {
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
