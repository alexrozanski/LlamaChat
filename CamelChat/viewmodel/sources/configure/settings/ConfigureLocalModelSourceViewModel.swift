//
//  ConfigureLocalModelSourceViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine

class ConfigureLocalModelSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  typealias AddSourceHandler = (ChatSource) -> Void
  typealias GoBackHandler = () -> Void

  private lazy var nameGenerator = SourceNameGenerator()

  // MARK: - Info

  @Published var name: String

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
  private let addSourceHandler: AddSourceHandler
  private let goBackHandler: GoBackHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    defaultName: String? = nil,
    chatSourceType: ChatSourceType,
    exampleGgmlModelPath: String,
    addSourceHandler: @escaping AddSourceHandler,
    goBackHandler: @escaping GoBackHandler
  ) {
    self.name = defaultName ?? ""
    self.chatSourceType = chatSourceType
    self.exampleGgmlModelPath = exampleGgmlModelPath
    self.addSourceHandler = addSourceHandler
    self.goBackHandler = goBackHandler
    navigationViewModel = ConfigureSourceNavigationViewModel()
    navigationViewModel.delegate = self

    let settingsValid = $settingsViewModel
      .compactMap { $0 }
      .map { $0.settingsValid }
      .switchToLatest()

    $name
      .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .combineLatest(settingsValid)
      .sink { [weak self] nameValid, settingsValid in
        self?.navigationViewModel.canContinue = nameValid && settingsValid
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
  func goBack() {
    goBackHandler()
  }

  func next() {
    guard let modelPath = settingsViewModel?.modelPath, let modelSize = settingsViewModel?.modelSize else { return }
    addSourceHandler(
      ChatSource(
        name: name,
        type: chatSourceType,
        modelURL: URL(fileURLWithPath: modelPath),
        modelSize: modelSize
      )
    )
  }
}
