//
//  SetupViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine

class SetupViewModel: ObservableObject {
  private let chatSources: ChatSources

  enum State {
    case none
    case selectingSource(viewModel: SelectSourceTypeViewModel)
    case configuringSource(viewModel: ConfigureSourceViewModel)
    case success
  }

  @Published var state = State.none

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
  }

  func start() {
    state = .selectingSource(viewModel: SelectSourceTypeViewModel(chatSources: chatSources, setupViewModel: self))
  }

  func goBack() {
    switch state {
    case .none, .selectingSource(viewModel: _), .success:
      break
    case .configuringSource(viewModel: _):
      state = .selectingSource(viewModel: SelectSourceTypeViewModel(chatSources: chatSources, setupViewModel: self))
    }
  }

  func configureSource(with type: ChatSourceType) {
    let viewModel: ConfigureSourceViewModel
    switch type {
    case .llama:
      viewModel = ConfigureLlamaSourceViewModel(setupViewModel: self)
    case .alpaca:
      viewModel = ConfigureAlpacaSourceViewModel()
    }

    state = .configuringSource(viewModel: viewModel)
  }

  func add(source: ChatSource) {
    chatSources.add(source: source)
    state = .success
  }
}
