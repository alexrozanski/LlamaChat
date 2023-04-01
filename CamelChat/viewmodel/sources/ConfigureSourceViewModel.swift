//
//  ConfigureSourceViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI
import Combine

protocol ConfigureSourceNavigationViewModelDelegate: AnyObject {
  func goBack()
  func next()
}

class ConfigureSourceNavigationViewModel: ObservableObject {
  @Published var canContinue: Bool = false

  weak var delegate: ConfigureSourceNavigationViewModelDelegate?

  init() {
    canContinue = false
  }

  func goBack() {
    delegate?.goBack()
  }

  func next() {
    delegate?.next()
  }
}

struct ConfigureSourceNavigationView: View {
  @ObservedObject var viewModel: ConfigureSourceNavigationViewModel

  var body: some View {
    HStack {
      Button("Back") {
        viewModel.goBack()
      }
      Spacer()
      Button("Add") {
        viewModel.next()
      }
      .keyboardShortcut(.return)
      .disabled(!viewModel.canContinue)
    }
  }
}

protocol ConfigureSourceViewModel {
  var navigationViewModel: ConfigureSourceNavigationViewModel { get }
}

@ViewBuilder func makeConfigureSourceView(from viewModel: ConfigureSourceViewModel) -> some View {
  VStack {
    if let viewModel = viewModel as? ConfigureLocalModelSourceViewModel {
      ConfigureLocalModelSourceView(viewModel: viewModel)
    } else if let viewModel = viewModel as? ConfigureAlpacaSourceViewModel {
      ConfigureAlpacaSourceView(viewModel: viewModel)
    } else {
      EmptyView()
    }
    Spacer()
    ConfigureSourceNavigationView(viewModel: viewModel.navigationViewModel)
  }
}
