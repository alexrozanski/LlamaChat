//
//  ConfigureModelViewModel.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import Foundation
import DataModel

class ModelSourceViewModel {
  let id = UUID().uuidString
  let title: String
  let description: String?
  let icon: String
  let source: ConfigureModelViewModel.ModelSource

  init(title: String, description: String?, icon: String, source: ConfigureModelViewModel.ModelSource) {
    self.title = title
    self.description = description
    self.icon = icon
    self.source = source
  }
}


class ConfigureModelViewModel: ObservableObject {
  enum ModelSource {
    case remote
    case local
  }

  enum State {
    case selectingSource
    case configuring

    var isSelectingSource: Bool {
      switch self {
      case .selectingSource:
        return true
      case .configuring:
        return false
      }
    }
  }

  var modelName: String { return model.name }

  @Published var selectedSource: ModelSource?
  @Published var isSelectingSource = false
  @Published var isConfiguringSource = false

  @Published private var state = State.selectingSource

  private let availableSourceViewModels: [ModelSourceViewModel]
  @Published var sourceViewModels = [ModelSourceViewModel]()

  private(set) lazy var primaryActionsViewModel = PrimaryActionsViewModel()

  private let model: Model

  init(model: Model) {
    self.model = model

    availableSourceViewModels = [
      ModelSourceViewModel(
        title: "Download models",
        description: "These models can be downloaded directly.",
        icon: "icloud.and.arrow.down",
        source: .remote
      ),
      ModelSourceViewModel(
        title: "Import models from your Mac",
        description: "If you've already downloaded the \(model.name) model files you can import these directly into LlamaChat.",
        icon: "desktopcomputer",
        source: .local
      )
    ].filter { source in
      switch source.source {
      case .local:
        return true
      case .remote:
        return model.source == .remote
      }
    }

    $selectedSource
      .combineLatest($state)
      .map { selectedSource, state in
        switch state {
        case .selectingSource:
          guard selectedSource != nil else {
            return PrimaryActionsButton(title: "Continue", disabled: true, action: {})
          }

          return PrimaryActionsButton(title: "Continue", action: { [weak self] in
            self?.confirmModelSource()
          })
        case .configuring:
          return PrimaryActionsButton(title: "Continue", disabled: true, action: {})
        }
      }
      .assign(to: &primaryActionsViewModel.$continueButton)

    $state
      .map { $0.isSelectingSource }
      .assign(to: &$isSelectingSource)

    $state
      .map { state in
        switch state {
        case .selectingSource:
          return false
        case .configuring:
          return true
        }
      }
      .assign(to: &$isConfiguringSource)

    $state
      .combineLatest($selectedSource)
      .map { [weak self] state, selectedSource in
        guard let self else { return [] }

        switch state {
        case .selectingSource:
          return self.availableSourceViewModels
        case .configuring:
          return self.availableSourceViewModels.filter { $0.source == selectedSource }
        }
      }
      .assign(to: &$sourceViewModels)
  }

  func confirmModelSource() {
    guard state.isSelectingSource else { return }

    state = .configuring
  }
}
