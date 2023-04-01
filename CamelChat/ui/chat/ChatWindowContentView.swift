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

  @State var selection: String?

  var body: some View {
    NavigationView {
      List(viewModel.sources, id: \.id) { source in
        NavigationLink(destination: ChatView(viewModel: source.makeChatViewModel()), tag: source.id, selection: $selection) {
          ChatWindowSourceItemView(viewModel: source)
        }
      }
      .listStyle(SidebarListStyle())
      .onAppear {
        selection = viewModel.sources.first?.id
      }
    }
  }
}
