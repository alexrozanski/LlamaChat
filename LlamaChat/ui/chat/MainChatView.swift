//
//  MainChatView.swift
//  Camel
//
//  Created by Alex Rozanski on 26/03/2023.
//

import SwiftUI

struct MainChatView: View {
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
      .toolbar {
        Spacer()
        Button {
          viewModel.presentAddSourceSheet()
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
    .sheet(isPresented: $viewModel.sheetPresented) {
      if let viewModel = viewModel.sheetViewModel as? ConfirmDeleteSourceSheetViewModel {
        ConfirmDeleteSourceSheetContentView(viewModel: viewModel)
      } else if let viewModel = viewModel.sheetViewModel as? AddSourceViewModel {
        AddSourceContentView(viewModel: viewModel)
          .interactiveDismissDisabled(true)
      }
    }
    .onAppear {
      initialWidth = nil
      selectedChatViewModel = viewModel.selectedSourceId.flatMap { viewModel.makeChatViewModel(for: $0) }
      viewModel.presentAddSourceSheetIfNeeded()
    }
    .onChange(of: viewModel.selectedSourceId) { newSourceId in
      selectedChatViewModel = newSourceId.flatMap { viewModel.makeChatViewModel(for: $0) }
    }
    .onChange(of: viewModel.sheetPresented) { isPresented in
      if !isPresented {
        viewModel.sheetViewModel = nil
      }
    }
  }
}
