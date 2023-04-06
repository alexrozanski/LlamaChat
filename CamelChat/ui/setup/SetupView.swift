//
//  SetupView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

struct SetupView: View {
  @ObservedObject var viewModel: SetupViewModel

  @ViewBuilder var content: some View {
    switch viewModel.state {
    case .none:
      EmptyView()
    case .selectingSource(viewModel: let viewModel):
      SelectSourceTypeView(viewModel: viewModel, presentationStyle: .embedded)
        .navigationTitle("Add model")
    case .configuringSource(viewModel: let viewModel):
      makeConfigureSourceView(from: viewModel, presentationStyle: .embedded)
        .navigationTitle(viewModel.chatSourceType.configureWindowTitle)
    case .success:
      AddSourceSuccessView()
    }
  }

  var body: some View {
    content
      .toolbar {
        if viewModel.state.canGoBack {
          ToolbarItem(placement: .navigation) {
            Button(action: {
              viewModel.goBack()
            }, label: { Image(systemName: "chevron.left") })
          }
        }

        // Dummy item so we always display a unified window/toolbar.
        if !viewModel.state.canGoBack {
          ToolbarItem { Text(" ") }
        }
      }
      .onAppear {
        viewModel.start()
      }
      .frame(width: 600, height: 380)
  }
}

fileprivate extension ChatSourceType {
  var configureWindowTitle: String {
    return "Add \(readableName) model"
  }
}
