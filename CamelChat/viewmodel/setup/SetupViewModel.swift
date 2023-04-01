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
    selectSource()
  }

  func goBack() {
    switch state {
    case .none, .selectingSource(viewModel: _), .success:
      break
    case .configuringSource(viewModel: _):
      selectSource()
    }
  }

  private func selectSource() {
    state = .selectingSource(
      viewModel: SelectSourceTypeViewModel(chatSources: chatSources, selectSourceHandler: { [weak self] sourceType in
        self?.configureSource(with: sourceType)
      })
    )
  }

  private func configureSource(with type: ChatSourceType) {
    let viewModel: ConfigureSourceViewModel
    switch type {
    case .llama:
      viewModel = makeConfigureLocalLlamaModelSourceViewModel(
        addSourceHandler: { [weak self] source in
          self?.add(source: source)
        }, goBackHandler: { [weak self] in
          self?.goBack()
        }
      )
    case .alpaca:
      viewModel = makeConfigureLocalAlpacaModelSourceViewModel(
        addSourceHandler: { [weak self] source in
          self?.add(source: source)
        }, goBackHandler: { [weak self] in
          self?.goBack()
        }
      )
    }
    
    state = .configuringSource(viewModel: viewModel)
  }

  func add(source: ChatSource) {
    chatSources.add(source: source)
    state = .success
  }
}
