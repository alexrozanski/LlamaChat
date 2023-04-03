//
//  ChatView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct ChatView: View {
  var viewModel: ChatViewModel

  @State var presentingInfo = false

  var body: some View {
    VStack(spacing: 0) {
      MessagesView(viewModel: viewModel.messagesViewModel)
      ComposeView(viewModel: viewModel.composeViewModel)
    }
    .toolbar {
      Button {
        presentingInfo = true
      } label: { Image(systemName: "info.circle")}
        .popover(isPresented: $presentingInfo, arrowEdge: .bottom) {
          ChatInfoView(viewModel: viewModel.infoViewModel)
        }
    }
  }
}
