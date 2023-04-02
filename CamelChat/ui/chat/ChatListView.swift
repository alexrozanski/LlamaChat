//
//  ChatListView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

fileprivate struct ItemView: View {
  @ObservedObject var viewModel: ChatListItemViewModel

  var body: some View {
    Text(viewModel.title)
  }
}


struct ChatListView: View {
  @ObservedObject var viewModel: ChatListViewModel
  
  var body: some View {
    let selectionBinding = Binding<String?>(
      get: { viewModel.selectedSourceId },
      set: { viewModel.selectSource(with: $0) }
    )
    HStack {
      List(viewModel.items, id: \.id, selection: selectionBinding) { source in
        ItemView(viewModel: source)
      }
    }
  }
}
