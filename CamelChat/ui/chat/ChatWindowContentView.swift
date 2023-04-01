//
//  ContentView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct ChatWindowSourceItemView: View {
  @ObservedObject var viewModel: ChatSourceViewModel

  var body: some View {
    Text(viewModel.title)
  }
}

struct ChatWindowContentView: View {
  @ObservedObject var viewModel: ChatSourcesViewModel

  @State var selectedSourceId: String?

  var body: some View {
    NavigationSplitView {
      List(viewModel.sources, id: \.id, selection: $selectedSourceId) { source in
        ChatWindowSourceItemView(viewModel: source)
      }
    } detail: {
      if let source = viewModel.chatSourceViewModel(with: selectedSourceId) {
        ChatView(viewModel: source.makeChatViewModel())
          .id(source.id)
      }
    }
  }
}
