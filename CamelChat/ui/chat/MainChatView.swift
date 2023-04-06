//
//  MainChatView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MainChatView: View {
  @Environment(\.openWindow) var openWindow

  @ObservedObject var viewModel: MainChatViewModel

  @State var initialWidth: Double?
  @State var selectedChatViewModel: ChatViewModel?

  init(viewModel: MainChatViewModel) {
    self.viewModel = viewModel
    _initialWidth = State(wrappedValue: viewModel.sidebarWidth)
  }

  @ViewBuilder var list: some View {
    GeometryReader { geometry in
      ChatListView(viewModel: viewModel.chatListViewModel)
      .overlay(
        Color.clear
          .onChange(of: geometry.size.width) { newWidth in
            viewModel.sidebarWidth = newWidth
          }
      )
      .overlay {
        SheetPresentingView(viewModel: viewModel.sheetViewModel) { viewModel in
          if let viewModel = viewModel as? ConfirmDeleteSourceSheetViewModel {
            ConfirmDeleteSourceSheetContentView(viewModel: viewModel)
          }
        }
      }
      .toolbar {
        Spacer()
        Button {
          openWindow(id: WindowIdentifier.setup.rawValue)
        } label: {
          Image(systemName: "square.and.pencil")
        }
      }
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
      if let viewModel = selectedChatViewModel {
        ChatView(viewModel: viewModel)
          .id(viewModel.sourceId)
      }
    }
    .onAppear {
      initialWidth = nil
      selectedChatViewModel = viewModel.selectedSourceId.flatMap { viewModel.makeChatViewModel(for: $0) }
    }
    .onChange(of: viewModel.selectedSourceId) { newSourceId in
      selectedChatViewModel = newSourceId.flatMap { viewModel.makeChatViewModel(for: $0) }
    }
  }
}
