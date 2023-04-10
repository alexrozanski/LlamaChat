//
//  ConfigureLocalModelSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine

struct ConfiguredSource {
  let name: String
  let avatarImageName: String?
  let settings: SourceSettings
}

class ConfigureLocalModelSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  typealias NextHandler = (ConfiguredSource) -> Void

  private lazy var nameGenerator = SourceNameGenerator()

  // MARK: - Info

  @Published var name: String
  @Published var avatarImageName: String?

  var modelType: String {
    return chatSourceType.readableName
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

  // MARK: - Validation

  let navigationViewModel: ConfigureSourceNavigationViewModel

  let chatSourceType: ChatSourceType
  let exampleGgmlModelPath: String
  private let nextHandler: NextHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    defaultName: String? = nil,
    chatSourceType: ChatSourceType,
    exampleGgmlModelPath: String,
    nextHandler: @escaping NextHandler
  ) {
    self.name = defaultName ?? ""
    self.chatSourceType = chatSourceType
    self.exampleGgmlModelPath = exampleGgmlModelPath
    self.nextHandler = nextHandler
    navigationViewModel = ConfigureSourceNavigationViewModel()
    navigationViewModel.delegate = self

    let configuredSource = $settingsViewModel
      .compactMap { $0 }
      .map { $0.sourceSettings }
      .switchToLatest()

    $name
      .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .combineLatest(configuredSource)
      .sink { [weak self] nameValid, configuredSource in
        self?.navigationViewModel.canContinue = nameValid && configuredSource != nil
      }.store(in: &subscriptions)

    $modelSourceType
      .sink { [weak self] newSourceType in
        self?.navigationViewModel.showContinueButton = newSourceType != nil

        if let newSourceType {
          switch newSourceType {
          case .pyTorch:
            self?.navigationViewModel.nextButtonTitle = "Continue"
          case .ggml:
            self?.navigationViewModel.nextButtonTitle = "Add"
          }
        }
      }.store(in: &subscriptions)
  }

  func generateName() {
    if let generatedName = nameGenerator.generateName(for: chatSourceType) {
      name = generatedName
    }
  }

  func select(modelSourceType: ConfigureLocalModelSourceType?) {
    self.modelSourceType = modelSourceType
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

extension ConfigureLocalModelSourceViewModel: ConfigureSourceNavigationViewModelDelegate {
  func next() {
    guard let sourceSettings = settingsViewModel?.sourceSettings.value else { return }
    nextHandler(
      ConfiguredSource(name: name, avatarImageName: avatarImageName, settings: sourceSettings)
    )
  }
}
