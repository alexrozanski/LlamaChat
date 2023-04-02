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
      SelectSourceTypeView(viewModel: viewModel)
        .navigationTitle("Add model")
    case .configuringSource(viewModel: let viewModel):
      makeConfigureSourceView(from: viewModel)
        .navigationTitle("Configure model")
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
  }
}
