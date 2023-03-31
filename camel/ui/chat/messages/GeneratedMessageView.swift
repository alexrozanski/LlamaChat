//
//  GeneratedMessageView.swift
//  Camel
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct GeneratedMessageView: View {
  @ObservedObject var viewModel: GeneratedMessageViewModel

  var body: some View {
    VStack(alignment: .leading) {
      if showStopButton {
        Button(action: {
          viewModel.stopGeneratingContent()
        }) {
          Text("Stop generating response")
            .font(.footnote)
            .foregroundColor(.blue)
        }
        .buttonStyle(BorderlessButtonStyle())
      }
      MessageBubbleView(sender: viewModel.sender) {
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
