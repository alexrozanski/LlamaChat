//
//  ConfigureLocalGgmlModelSettingsViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import Combine
import llama

class ConfigureLocalPyTorchModelSettingsViewModel: ObservableObject, ConfigureLocalModelSettingsViewModel {
  var sourceType: ConfigureLocalModelSourceType {
    return .pyTorch
  }

  var modelPath: String? { return nil }
  var modelSize: ModelSize? {
    return modelSizePickerViewModel.modelSize
  }

  @Published private(set) var requiredNumberOfModelFiles = 1
  @Published private(set) var showPathSelector = false

  enum ConversionState {
    case unknown
    case loading
    case canConvert(Bool)

    var isUnknown: Bool {
      switch self {
      case .unknown: return true
      case .loading, .canConvert: return false
      }
    }

    var canConvert: Bool {
      switch self {
      case .canConvert(let canConvert): return canConvert
      case .unknown, .loading: return false
      }
    }
  }

  @Published var conversionState: ConversionState = .unknown
  @Published var files: [ModelConversionFile]? = nil

  private(set) lazy var modelSizePickerViewModel = ConfigureLocalModelSizePickerViewModel(labelProvider: { modelSize, defaultProvider in
    switch modelSize {
    case .unknown:
      return "Select Model Size"
    case .size7B, .size13B, .size30B, .size65B:
      let numFiles = modelSize.requiredNumberOfModelFiles
      return "\(defaultProvider(modelSize)) (\(numFiles) \(numFiles == 1 ? "file" : "files"))"
    }
  })
  private(set) lazy var pathSelectorViewModel = ConfigureLocalModelPathSelectorViewModel(
    customLabel: "Model Directory",
    selectionMode: .directories
  )

  let chatSourceType: ChatSourceType
  let settingsValid = CurrentValueSubject<Bool, Never>(false)

  private var subscriptions = Set<AnyCancellable>()

  init(chatSourceType: ChatSourceType) {
    self.chatSourceType = chatSourceType

    modelSizePickerViewModel.$modelSize.sink { [weak self] newModelSize in
      guard let self else { return }
      self.requiredNumberOfModelFiles = newModelSize.requiredNumberOfModelFiles
    }.store(in: &subscriptions)
    modelSizePickerViewModel.$modelSize
      .combineLatest($conversionState)
      .sink { [weak self] modelSize, conversionState in
        self?.showPathSelector = !modelSize.isUnknown && conversionState.canConvert
      }.store(in: &subscriptions)

    pathSelectorViewModel.$modelPaths
      .combineLatest(modelSizePickerViewModel.$modelSize)
      .sink { [weak self] modelPaths, modelSize in
        guard let self else { return }

        guard let modelPath = modelPaths.first else {
          self.pathSelectorViewModel.modelState = .none
          return
        }

        let data = ConvertPyTorchToGgmlConversion.Data(
          modelType: modelSize.toModelType(),
          directoryURL: URL(fileURLWithPath: modelPath)
        )
        let result = ModelConverter.validateData(data, requiredFiles: &self.files)
        switch result {
        case .success:
          self.pathSelectorViewModel.modelState = .valid
        case .failure(let error):
          var errorMessage: String
          switch error {
          case .missingParamsFile(filename: let filename):
            errorMessage = "Directory doesn't contain params file '\(filename)'"
          case .missingTokenizerFile(filename: let filename):
            errorMessage = "Directory doesn't contain tokenizer file '\(filename)'"
          case .missingPyTorchCheckpoint(filename: let filename):
            errorMessage = "Directory doesn't contain PyTorch checkpoint file '\(filename)'"
          }
          self.pathSelectorViewModel.modelState = .invalid(message: errorMessage)
        }

        ConvertPyTorchToGgmlConversion.requiredFiles(for: data).map { $0.path }
      }.store(in: &subscriptions)
  }

  func determineConversionStateIfNeeded() {
    guard conversionState.isUnknown else { return }

    conversionState = .loading
    Task.init {
      let canConvert = await ModelConverter.canRunConversion()
      await MainActor.run {
        conversionState = .canConvert(canConvert)
      }
    }
  }
}

fileprivate extension ModelSize {
  var requiredNumberOfModelFiles: Int {
    switch self {
    case .unknown: return 0
    case .size7B: return 1
    case .size13B: return 2
    case .size30B: return 4
    case .size65B: return 8
    }
  }

  func toModelType() -> ModelType {
    switch self {
    case .unknown: return .unknown
    case .size7B: return .size7B
    case .size13B: return .size13B
    case .size30B: return .size30B
    case .size65B: return .size65B
    }
  }
}
