//
//  ConfigureLocalModelSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine
import SwiftUI

class ConfigureLocalModelSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  // MARK: - Info  

  var modelType: String {
    return chatSourceType.readableName
  }

  var modelSourcingDescription: LocalizedStringKey {
    switch chatSourceType {
    case .llama:
      return "The LLaMA model checkpoints and tokenizer are required to add this chat source. Learn more and request access to these on the [LLaMA GitHub repo](https://github.com/facebookresearch/llama)."
    case .alpaca:
      return "The Alpaca model checkpoints and tokenizer are required to add this chat source. Learn more on the [Alpaca GitHub repo](https://github.com/tatsu-lab/stanford_alpaca)."
    case .gpt4All:
      return "The GPT4All .ggml model file is required to add this chat source. Learn more on the [llama.cpp GitHub repo](https://github.com/ggerganov/llama.cpp/blob/a0caa34/README.md#using-gpt4all)."
    }
  }

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
          let viewModel = ConfigureLocalPyTorchModelSettingsViewModel(chatSourceType: chatSourceType)
          viewModel.determineConversionStateIfNeeded()
          settingsViewModels[.pyTorch] = viewModel
          settingsViewModel = viewModel
        case .ggml:
          let viewModel = ConfigureLocalGgmlModelSettingsViewModel(
            chatSourceType: chatSourceType,
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

  let chatSourceType: ChatSourceType
  let exampleGgmlModelPath: String
  private let nextHandler: ConfigureSourceNextHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    defaultName: String? = nil,
    chatSourceType: ChatSourceType,
    exampleGgmlModelPath: String,
    nextHandler: @escaping ConfigureSourceNextHandler
  ) {
    detailsViewModel = ConfigureSourceDetailsViewModel(defaultName: defaultName, chatSourceType: chatSourceType)
    self.chatSourceType = chatSourceType
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
      ConfiguredSource(name: detailsViewModel.name, avatarImageName: detailsViewModel.avatarImageName, settings: sourceSettings)
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
