//
//  ChatView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct ChatView: View {
  var viewModel: ChatViewModel  

  var body: some View {
    VStack {
      MessagesView(viewModel: viewModel.messagesViewModel)
      ComposeView(viewModel: viewModel.composeViewModel)
    }
  }
}
