//
//  DebouncedView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct DebouncedView<Content>: View where Content: View {
  typealias ContentBuilder = () -> Content

  @State private var showView = false

  let delay: Double
  let contentBuilder: ContentBuilder
  init(delay: Double, contentBuilder: @escaping ContentBuilder) {
    self.delay = delay
    self.contentBuilder = contentBuilder
  }

  var body: some View {
    VStack {
      if showView {
        contentBuilder()
      }
    }
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        self.showView = true
      }
    }
  }
}
