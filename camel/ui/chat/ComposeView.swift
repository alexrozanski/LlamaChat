//
//  ComposeView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct RoundedTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding(.horizontal, 12)
      .padding(.vertical, 4)
      .background(
        RoundedRectangle(cornerRadius: 15)
          .fill(.white)
          .overlay {
            RoundedRectangle(cornerRadius: 15)
              .stroke(.gray)
          }
      )
  }
}

struct ComposeView: View {
  @ObservedObject var viewModel: ComposeViewModel

  @FocusState private var isFocused: Bool

  var body: some View {
    HStack {
      TextField("Chat here...", text: $viewModel.text, axis: .vertical)
        .textFieldStyle(RoundedTextFieldStyle())
        .focused($isFocused)
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
