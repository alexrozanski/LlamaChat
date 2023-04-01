//
//  ConfigureSourceViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

protocol ConfigureSourceViewModel {}

@ViewBuilder func makeConfigureSourceView(for viewModel: ConfigureSourceViewModel) -> some View {
  if let viewModel = viewModel as? ConfigureLlamaSourceViewModel {
    ConfigureLlamaSourceView(viewModel: viewModel)
  } else if let viewModel = viewModel as? ConfigureAlpacaSourceViewModel {
    ConfigureAlpacaSourceView(viewModel: viewModel)
  } else {
    EmptyView()
  }
}
