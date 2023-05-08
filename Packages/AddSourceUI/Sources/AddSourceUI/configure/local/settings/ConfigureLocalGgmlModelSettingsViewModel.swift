//
//  ConfigureLocalGgmlModelSettingsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import Combine
import CameLLM
import CameLLMLlama
import DataModel
import ModelMetadata

private func getInvalidModelTypeReason(from error: Error) -> ConfigureLocalGgmlModelSettingsViewModel.InvalidModelTypeReason {
  // Reason is always stored in the underlying error
  guard let underlyingError = ((error as NSError).underlyingErrors as [NSError]).first(where: { $0.domain == CameLLMError.Domain }) else {
    return .unknown
  }

  if underlyingError.code == CameLLMError.Code.invalidModelBadMagic.rawValue {
    return .invalidFileType
  }

  if underlyingError.code == CameLLMError.Code.invalidModelUnversioned.rawValue || underlyingError.code == CameLLMError.Code.invalidModelUnsupportedFileVersion.rawValue {
    return .unsupportedModelVersion
  }

  return .unknown
}

class ConfigureLocalGgmlModelSettingsViewModel: ObservableObject, ConfigureLocalModelSettingsViewModel {
  enum InvalidModelTypeReason {
    case unknown
    case invalidFileType
    case unsupportedModelVersion
  }

  enum ModelState {
    case none
    case invalidPath
    case invalidModel(_ reason: InvalidModelTypeReason)
    case valid(modelURL: URL)

    var isValid: Bool {
      switch self {
      case .none, .invalidPath, .invalidModel:
        return false
      case .valid:
        return true
      }
    }
  }

  let sourceSettings = CurrentValueSubject<ConfiguredSourceSettings?, Never>(nil)

  var modelName: String {
    return model.name
  }

  var sourceType: ConfigureLocalModelSourceType {
    return .ggml
  }

  private(set) lazy var pathSelectorViewModel = PathSelectorViewModel()
  private(set) lazy var modelSizePickerViewModel = SizePickerViewModel(labelProvider: { modelSize, defaultProvider in
    switch modelSize {
    case .unknown:
      return "Not Specified"
    case .size7B, .size13B, .size30B, .size65B:
      return defaultProvider(modelSize)
    }
  })

  @Published private(set) var modelState: ModelState = .none

  var modelPath: String? { return pathSelectorViewModel.modelPaths.first }
  var modelSize: ModelSize? { return modelSizePickerViewModel.modelSize }

  let model: Model
  let exampleModelPath: String

  private var subscriptions = Set<AnyCancellable>()

  init(model: Model, exampleModelPath: String) {
    self.model = model
    self.exampleModelPath = exampleModelPath

    pathSelectorViewModel.$modelPaths.sink { [weak self] newPaths in
      guard let self, let modelPath = newPaths.first else {
        self?.modelState = .none
        return
      }

      guard FileManager().fileExists(atPath: modelPath) else {
        self.modelState = .invalidPath
        return
      }

      let modelURL = URL(fileURLWithPath: modelPath)
      do {
        try ModelUtils.llamaFamily.validateModel(at: modelURL)
      } catch {
        print(error)
        self.modelState = .invalidModel(getInvalidModelTypeReason(from: error))
        return
      }

      self.modelState = .valid(modelURL: modelURL)

      do {
        self.modelSizePickerViewModel.modelSize = (try ModelUtils.llamaFamily.getModelCard(forFileAt: URL(fileURLWithPath: modelPath)))?.modelType.toModelSize() ?? .unknown
      } catch {
        print(error)
      }
    }.store(in: &subscriptions)

    $modelState.sink { [weak self] newModelState in
      switch newModelState {
      case .none, .valid:
        self?.pathSelectorViewModel.errorMessage = nil
      case .invalidPath:
        self?.pathSelectorViewModel.errorMessage = "Selected file is invalid"
      case .invalidModel(let reason):
        switch reason {
        case .unknown, .invalidFileType:
          self?.pathSelectorViewModel.errorMessage = "Selected file is not a valid model"
        case .unsupportedModelVersion:
          self?.pathSelectorViewModel.errorMessage = "Selected model is of an unsupported version"
        }
      }
    }.store(in: &subscriptions)

    $modelState
      .combineLatest(modelSizePickerViewModel.$modelSize)
      .sink { [weak self] modelState, modelSize in
        guard !modelSize.isUnknown else {
          self?.sourceSettings.send(nil)
          return
        }

        switch modelState {
        case .none, .invalidModel, .invalidPath:
          self?.sourceSettings.send(nil)
        case .valid(modelURL: let modelURL):
          self?.sourceSettings.send(.ggmlModel(modelURL: modelURL))
        }
      }.store(in: &subscriptions)
  }
}

fileprivate extension ModelType {
  func toModelSize() -> ModelSize {
    switch self {
    case .unknown: return .unknown
    case .size7B: return .size7B
    case .size13B: return .size13B
    case .size30B: return .size30B
    case .size65B: return .size65B
    }
  }
}
