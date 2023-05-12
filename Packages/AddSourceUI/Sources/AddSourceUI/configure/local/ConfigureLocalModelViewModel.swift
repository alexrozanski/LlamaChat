//
//  ConfigureLocalModelViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine
import SwiftUI
import DataModel
import ModelMetadata

class ConfigureLocalModelViewModel: ObservableObject {
  typealias ConfigureSourceNextHandler = (ConfiguredSource) -> Void

  // MARK: - Info

  var modelName: String {
    return model.name
  }

  lazy var modelSourcingDescription: AttributedString? = {
    return model.sourcingDescription.flatMap { try? AttributedString(markdown: $0) }
  }()

  // MARK: - Model Settings


  @Published var modelSourceType: ConfigureLocalModelSourceType?
  @Published private(set) var settingsViewModel: ConfigureLocalModelSettingsViewModel?

  private var settingsViewModels = [ConfigureLocalModelSourceType: ConfigureLocalModelSettingsViewModel]()

  // MARK: - Validation

  let primaryActionsViewModel = PrimaryActionsViewModel()

  let model: Model
  let modelVariant: ModelVariant?
  private let nextHandler: ConfigureSourceNextHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    defaultName: String? = nil,
    model: Model,
    modelVariant: ModelVariant?,
    nextHandler: @escaping ConfigureSourceNextHandler
  ) {
    self.model = model
    self.modelVariant = modelVariant
    self.nextHandler = nextHandler

    let configuredSource = $settingsViewModel
      .compactMap { $0 }
      .map { $0.sourceSettings }
      .switchToLatest()

    $modelSourceType
      .map { [weak self] sourceType in
        return sourceType.flatMap { self?.makeOrGetSettingsViewModel(for: $0) }
      }
      .assign(to: &$settingsViewModel)

    let canContinue = configuredSource
      .map { configuredSource in
        return configuredSource != nil
      }

    $modelSourceType
      .combineLatest(canContinue)
      .map { newSourceType, canContinue in
        guard let newSourceType else { return nil }
        switch newSourceType {
        case .pyTorch:
          return PrimaryActionsButton(title: "Continue", disabled: !canContinue) {
            [weak self] in self?.next()
          }
        case .ggml:
          return PrimaryActionsButton(title: "Add", disabled: !canContinue) {
            [weak self] in self?.next()
          }
        }
      }.assign(to: &primaryActionsViewModel.$continueButton)
  }

  func next() {
    guard let sourceSettings = settingsViewModel?.sourceSettings.value else { return }
    nextHandler(
      ConfiguredSource(
        model: model,
        settings: sourceSettings
      )
    )
  }

  private func makeOrGetSettingsViewModel(for modelSourceType: ConfigureLocalModelSourceType) -> ConfigureLocalModelSettingsViewModel {
    if let existingModel = settingsViewModels[modelSourceType] {
      return existingModel
    }

    switch modelSourceType {
    case .pyTorch:
      let viewModel = ConfigureLocalPyTorchModelSettingsViewModel(model: model, modelVariant: modelVariant)
      viewModel.determineConversionStateIfNeeded()
      settingsViewModels[.pyTorch] = viewModel
      return viewModel
    case .ggml:
      let viewModel = ConfigureLocalGgmlModelSettingsViewModel(model: model, modelVariant: modelVariant)
      settingsViewModels[.ggml] = viewModel
      return viewModel
    }
  }
}
