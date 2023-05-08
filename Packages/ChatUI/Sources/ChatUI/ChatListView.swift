//
//  ChatListView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI
import SettingsUI
import SharedUI

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
        SettingsWindowPresenter.shared.present(deeplinkingTo: .sources(sourceId: viewModel.id, sourcesTab: .properties))
      }
      Divider()
      Button("Remove...") {
        viewModel.remove()
      }
    }
  }
}


public struct ChatListView: View {
  @ObservedObject public var viewModel: ChatListViewModel
  
  public var body: some View {
    let selectionBinding = Binding<String>(
      get: { viewModel.selectedSourceId ?? "" },
      set: { viewModel.selectSource(with: $0) }
    )
    HStack {
      List(selection: selectionBinding) {
        ForEach(viewModel.items, id: \.id) { item in
          ItemView(viewModel: item)
        }
        .onMove { from, to in
          viewModel.moveItems(fromOffsets: from, toOffset: to)
        }
      }
    }
  }
}
