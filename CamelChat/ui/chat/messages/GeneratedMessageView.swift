//
//  GeneratedMessageView.swift
//  Camel
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct GeneratedMessageView: View {
  @ObservedObject var viewModel: GeneratedMessageViewModel

  let availableWidth: Double

  var body: some View {
    VStack(alignment: .leading) {
      if showStopButton {
        DebouncedView(delay: 0.5) {
          Button(action: {
            viewModel.stopGeneratingContent()
          }) {
            Text("Stop generating response")
              .font(.footnote)
              .foregroundColor(.blue)
          }
          .buttonStyle(BorderlessButtonStyle())
        }
      }
      MessageBubbleView(sender: viewModel.sender, style: viewModel.state.isWaiting ? .typing: .regular, isError: viewModel.isError, availableWidth: availableWidth) {
        switch viewModel.state {
        case .none:
          EmptyView()
        case .waiting:
          TypingBubbleContentView()
        case .generating, .finished, .cancelled, .error:
          Text(viewModel.content)
        }
      }
    }
  }

  private var showStopButton: Bool {
    switch viewModel.state {
    case .none, .waiting, .finished, .cancelled, .error:
      return false
    case .generating:
      return true
    }
  }
}
