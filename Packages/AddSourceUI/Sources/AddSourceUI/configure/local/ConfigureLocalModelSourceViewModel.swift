//
//  ConfigureLocalModelSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine
import SwiftUI
import DataModel
import ModelMetadata

class ConfigureLocalModelSourceViewModel: ObservableObject {
  typealias ConfigureSourceNextHandler = (ConfiguredSource) -> Void

  // MARK: - Info

  var modelName: String {
    return model.name
  }

  lazy var modelSourcingDescription: AttributedString? = {
    return model.sourcingDescription.flatMap { try? AttributedString(markdown: $0) }
  }()

  // MARK: - Model Settings

  var settingsViewModels = [ConfigureLocalModelSourceType: ConfigureLocalModelSettingsViewModel]()

  @Published private(set) var modelSourceType: ConfigureLocalModelSourceType? = nil {
    didSet {
      guard let modelSourceType else {
        settingsViewModel = nil
        return
      }

      if let existingModel = settingsViewModels[modelSourceType] {
        settingsViewModel = existingModel
      } else {
        switch modelSourceType {
        case .pyTorch:
          let viewModel = ConfigureLocalPyTorchModelSettingsViewModel()
          viewModel.determineConversionStateIfNeeded()
          settingsViewModels[.pyTorch] = viewModel
          settingsViewModel = viewModel
        case .ggml:
          let viewModel = ConfigureLocalGgmlModelSettingsViewModel(
            model: model,
            exampleModelPath: exampleGgmlModelPath
          )
          settingsViewModels[.ggml] = viewModel
          settingsViewModel = viewModel
        }
      }
    }
  }

  @Published private(set) var settingsViewModel: ConfigureLocalModelSettingsViewModel?

  let detailsViewModel: ConfigureSourceDetailsViewModel

  // MARK: - Validation

  let primaryActionsViewModel = ConfigureSourcePrimaryActionsViewModel()

  let model: Model
  let exampleGgmlModelPath: String
  private let nextHandler: ConfigureSourceNextHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    defaultName: String? = nil,
    model: Model,
    exampleGgmlModelPath: String,
    nextHandler: @escaping ConfigureSourceNextHandler
  ) {
    detailsViewModel = ConfigureSourceDetailsViewModel(defaultName: defaultName, model: model)
    self.model = model
    self.exampleGgmlModelPath = exampleGgmlModelPath
    self.nextHandler = nextHandler

    let configuredSource = $settingsViewModel
      .compactMap { $0 }
      .map { $0.sourceSettings }
      .switchToLatest()

    let canContinue = detailsViewModel.$name
      .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .combineLatest(configuredSource)
      .map { nameValid, configuredSource in
        return nameValid && configuredSource != nil
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

  func select(modelSourceType: ConfigureLocalModelSourceType?) {
    self.modelSourceType = modelSourceType
  }

  func next() {
    guard let sourceSettings = settingsViewModel?.sourceSettings.value else { return }
    nextHandler(
      ConfiguredSource(
        name: detailsViewModel.name,
        avatarImageName: detailsViewModel.avatarImageName,
        model: model,
        modelVariant: nil,
        settings: sourceSettings
      )
    )
  }
}

extension ConfigureLocalModelSourceType {
  var label: String {
    switch self {
    case .pyTorch: return "PyTorch Checkpoint (.pth)"
    case .ggml: return "GGML (.ggml)"
    }
  }
}
