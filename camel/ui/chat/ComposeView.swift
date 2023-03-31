//
//  ComposeView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct ComposeView: View {
  @ObservedObject var viewModel: ComposeViewModel

  @FocusState private var isFocused: Bool

  var body: some View {
    let canSendMessage = !viewModel.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    HStack(spacing: 4) {
      BorderlessTextField("Chat here...", text: $viewModel.text)
        .focused($isFocused)
        .padding(.vertical, 4)
      if canSendMessage {
        Button(action: {
          viewModel.send(message: viewModel.text)
        }, label: {
          Image(systemName: "arrow.up")
            .padding(3)
            .foregroundColor(.white)
            .background(.blue)
            .clipShape(Circle())
        })
        .buttonStyle(BorderlessButtonStyle())
        .keyboardShortcut(.return, modifiers: [])
      }
    }
    .padding(.vertical, 2)
    .padding(.leading, 10)
    .padding(.trailing, 5)
    .background(
      RoundedRectangle(cornerRadius: 15)
        .fill(.white)
        .overlay {
          RoundedRectangle(cornerRadius: 15)
            .stroke(Color(NSColor.separatorColor.cgColor))
        }
    )
    .padding()
    .onAppear {
      isFocused = true
    }
  }
}
