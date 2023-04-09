//
//  ChatListView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

fileprivate struct ItemView: View {
  @ObservedObject var viewModel: ChatListItemViewModel

  var body: some View {
    HStack {
      AvatarView(viewModel: viewModel.avatarViewModel, size: .medium)
      VStack(alignment: .leading, spacing: 4) {
        Text(viewModel.title)
          .font(.system(size: 13, weight: .semibold))
        Text(viewModel.modelDescription)
          .font(.system(size: 11))
      }
    }
    .padding(8)
    .contextMenu {
      Button("Configure...") {
        NSApp.showSettingsWindow()
      }
      Divider()
      Button("Remove...") {
        viewModel.remove()
      }
    }
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
