//
//  ConfigureModelViewModel.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import Foundation
import Combine
import CardUI
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
  typealias NextHandler = (ConfiguredSource) -> Void

  enum ModelSource {
    case remote
    case local
  }

  enum State {
    case selectingSource
    case configuringLocalModel(ConfigureLocalModelViewModel)
    case configuringRemoteModel(ConfigureDownloadableModelViewModel)

    var isSelectingSource: Bool {
      switch self {
      case .selectingSource:
        return true
      case .configuringLocalModel, .configuringRemoteModel:
        return false
      }
    }

    var configureLocalModelViewModel: ConfigureLocalModelViewModel? {
      switch self {
      case .selectingSource, .configuringRemoteModel:
        return nil
      case .configuringLocalModel(let viewModel):
        return viewModel
      }
    }

    var configureDownloadableModelViewModel: ConfigureDownloadableModelViewModel? {
      switch self {
      case .selectingSource, .configuringLocalModel:
        return nil
      case .configuringRemoteModel(let viewModel):
        return viewModel
      }
    }
  }

  var modelName: String { return model.name }

  @Published var selectedSource: ModelSource?

  @Published var isSourceSelectable: Bool
  @Published var isSelectingSource = false
  @Published var isConfiguringSource = false

  @Published private(set) var state = State.selectingSource

  private let availableSourceViewModels: [ModelSourceViewModel]
  @Published var sourceViewModels = [ModelSourceViewModel]()

  @Published private(set) var primaryActionsViewModel = PrimaryActionsViewModel()

  private var subscriptions = Set<AnyCancellable>()

  private let model: Model
  private let variant: ModelVariant?
  private let nextHandler: NextHandler

  init(
    model: Model,
    variant: ModelVariant?,
    nextHandler: @escaping NextHandler
  ) {
    self.model = model
    self.variant = variant
    self.nextHandler = nextHandler

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

    isSourceSelectable = availableSourceViewModels.count > 1

    $selectedSource
      .map { selectedSource in
        guard selectedSource != nil else {
          return PrimaryActionsButton(title: "Continue", disabled: true, action: {})
        }

        return PrimaryActionsButton(title: "Continue", action: { [weak self] in
          self?.confirmModelSource()
        })
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
        case .configuringLocalModel, .configuringRemoteModel:
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
        case .configuringLocalModel:
          return self.availableSourceViewModels.filter { $0.source == .local }
        case .configuringRemoteModel:
          return self.availableSourceViewModels.filter { $0.source == .remote }
        }
      }
      .assign(to: &$sourceViewModels)

    if availableSourceViewModels.count == 1, let sourceModel = availableSourceViewModels.first {
      select(source: sourceModel.source)
    }
  }

  func confirmModelSource() {
    guard state.isSelectingSource, let selectedSource else { return }
    select(source: selectedSource)
  }

  private func select(source: ModelSource) {
    switch source {
    case .local:
      state = .configuringLocalModel(
        ConfigureLocalModelViewModel(
          model: model,
          modelVariant: variant,
          nextHandler: nextHandler
        )
      )
    case .remote:
      guard let variant, let downloadURL = variant.downloadUrl else {
        break
      }

      state = .configuringRemoteModel(
        ConfigureDownloadableModelViewModel(
          model: model,
          modelVariant: variant,
          downloadURL: downloadURL,
          nextHandler: nextHandler
        )
      )
    }
  }
}
