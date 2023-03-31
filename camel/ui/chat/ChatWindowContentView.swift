//
//  ContentView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct ChatWindowContentView: View {
  @StateObject var viewModel: ChatViewModel

  init(chatModel: ChatModel, chatSources: ChatSources) {
    _viewModel = StateObject(wrappedValue: ChatViewModel(chatModel: chatModel, chatSources: chatSources))
  }

  var body: some View {
    NavigationView {
      ChatListView(viewModel: viewModel.chatSourcesViewModel)
      ChatView(viewModel: viewModel)
    }
  }
}
