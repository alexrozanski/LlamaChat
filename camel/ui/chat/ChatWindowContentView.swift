//
//  ContentView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct ChatWindowContentView: View {
  var chatModel: ChatModel
  @StateObject var viewModel: ChatViewModel

  init(chatModel: ChatModel) {
    self.chatModel = chatModel
    _viewModel = StateObject(wrappedValue: ChatViewModel(chatModel: chatModel))
  }

  var body: some View {
    NavigationView {
      ChatListView()
      ChatView(viewModel: viewModel)
    }
  }
}
