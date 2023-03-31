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
    HStack {
      BorderlessTextField("Chat here...", text: $viewModel.text)
        .focused($isFocused)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(
          RoundedRectangle(cornerRadius: 15)
            .fill(.white)
            .overlay {
              RoundedRectangle(cornerRadius: 15)
                .stroke(Color(NSColor.separatorColor.cgColor))
            }
        )
      Button(action: {
        viewModel.send(message: viewModel.text)
      }, label: {
        Text("Send")
      })
    }
    .padding()
    .onAppear {
      isFocused = true
    }
  }
}
