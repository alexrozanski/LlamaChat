//
//  SetupContentView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

struct SetupWindowContentView: View {
  @ObservedObject var viewModel: SetupViewModel

  @ViewBuilder var content: some View {
    switch viewModel.state {
    case .none:
      EmptyView()
    case .selectingSource(viewModel: let viewModel):
      SelectSourceTypeView(viewModel: viewModel)
    case .configuringSource(viewModel: let viewModel):
      if let viewModel = viewModel as? ConfigureLlamaSourceViewModel {
        ConfigureLlamaSourceView(viewModel: viewModel)
      } else if let viewModel = viewModel as? ConfigureAlpacaSourceViewModel {
        ConfigureAlpacaSourceView(viewModel: viewModel)
      } else {
        EmptyView()
      }
    case .success:
      AddSourceSuccessView()
    }
  }

  var body: some View {
    content
    .padding(32)
  }
}
