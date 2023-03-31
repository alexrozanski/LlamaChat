//
//  ContentView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct ChatWindowContentView: View {
  @StateObject var viewModel: ChatSourcesViewModel

  @State var selection: String?

  var body: some View {
    NavigationView {
      List(viewModel.sources, id: \.id) { source in
        NavigationLink(destination: ChatView(viewModel: source.makeChatViewModel()), tag: source.id, selection: $selection) {
          Text(source.title)
        }
      }
      .listStyle(SidebarListStyle())
      .onAppear {
        selection = viewModel.sources.first?.id
      }
    }
  }
}
