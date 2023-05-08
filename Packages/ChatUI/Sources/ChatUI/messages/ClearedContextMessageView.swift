//
//  ClearedContextMessageView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 05/04/2023.
//

import SwiftUI

struct LineView: View {
  var body: some View {
    Rectangle()
      .fill(.separator)
      .frame(height: 1)
  }
}

struct ClearedContextMessageView: View {
  let viewModel: ClearedContextMessageViewModel

  var body: some View {
    HStack(spacing: 8) {
      LineView()
      Text("Chat context cleared")
        .foregroundColor(.gray)
        .font(.footnote)
      LineView()
    }
    .padding(.vertical)
  }
}
