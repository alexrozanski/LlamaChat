//
//  GeneratedMessageView.swift
//  Camel
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct GeneratedMessageView: View {
  @ObservedObject var viewModel: GeneratedMessageViewModel

  let availableWidth: Double?

  var body: some View {
    VStack(alignment: .leading) {
      HStack {
        DebouncedView(isVisible: showStopButton, delay: 0.5, animation: .easeInOut(duration: 0.1)) {
          Button(action: {
            viewModel.stopGeneratingContent()
          }) {
            Text("Stop generating response")
              .font(.footnote)
              .foregroundColor(.blue)
          }
          .buttonStyle(BorderlessButtonStyle())
          .transition(.asymmetric(insertion: .scale(scale: 0.5), removal: .move(edge: .top)))
        }
      }
      switch viewModel.state {
      case .none:
        EmptyView()
      case .waiting:
        TypingBubbleView()
      case .generating, .finished, .cancelled, .error:
        MessageBubbleView(sender: viewModel.sender, style: viewModel.state.isWaiting ? .typing: .regular, isError: viewModel.isError, availableWidth: availableWidth) {
          Text(viewModel.content)
            .textSelectionEnabled(viewModel.canCopyContents.value)
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
