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
  @ObservedObject var viewModel: ChatWindowContentViewModel

  @State var initialWidth: Double?

  init(viewModel: ChatWindowContentViewModel) {
    self.viewModel = viewModel
    _initialWidth = State(wrappedValue: viewModel.sidebarWidth)
  }

  @ViewBuilder var list: some View {
    GeometryReader { geometry in
      HStack {
        List(viewModel.chatSourcesViewModel.sources, id: \.id, selection: $viewModel.selectedSourceId) { source in
          ChatWindowSourceItemView(viewModel: source)
        }
      }
      .overlay(
        Color.clear
          .onChange(of: geometry.size.width) { newWidth in
            viewModel.sidebarWidth = newWidth
          }
      )
    }
  }

  var body: some View {
    NavigationSplitView {
      if let initialWidth {
        list
          .frame(width: initialWidth)
      } else {
        list
      }
    } detail: {
      if let source = viewModel.chatSourcesViewModel.chatSourceViewModel(with: viewModel.selectedSourceId) {
        ChatView(viewModel: source.makeChatViewModel())
          .id(source.id)
      }
    }
    .onAppear {
      initialWidth = nil
    }
  }
}
