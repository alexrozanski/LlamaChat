//
//  ConfigureLocalGgmlModelSettingsViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import Combine
import llama

private func getInvalidModelTypeReason(from error: Error) -> ConfigureLocalModelInvalidModelTypeReason {
  // Reason is always stored in the underlying error
  guard let underlyingError = ((error as NSError).underlyingErrors as [NSError]).first(where: { $0.domain == LlamaError.Domain }) else {
    return .unknown
  }

  if underlyingError.code == LlamaError.Code.invalidModelBadMagic.rawValue {
    return .invalidFileType
  }

  if underlyingError.code == LlamaError.Code.invalidModelUnversioned.rawValue || underlyingError.code == LlamaError.Code.invalidModelUnsupportedFileVersion.rawValue {
    return .unsupportedModelVersion
  }

  return .unknown
}

class ConfigureLocalGgmlModelSettingsViewModel: ObservableObject, ConfigureLocalModelSettingsViewModel {
  let settingsValid = CurrentValueSubject<Bool, Never>(false)

  var sourceType: ConfigureLocalModelSourceType {
    return .ggml
  }

  private(set) lazy var pathSelectorViewModel = ConfigureLocalModelPathSelectorViewModel()
  private(set) lazy var modelSizePickerViewModel = ConfigureLocalModelSizePickerViewModel(labelProvider: { modelSize, defaultProvider in
    switch modelSize {
    case .unknown:
      return "Not Specified"
    case .size7B, .size13B, .size30B, .size65B:
      return defaultProvider(modelSize)
    }
  })

  @Published private(set) var modelState: ConfigureLocalModelState = .none

  var modelPath: String? { return pathSelectorViewModel.modelPaths.first }
  var modelSize: ModelSize? { return modelSizePickerViewModel.modelSize }

  let chatSourceType: ChatSourceType
  let exampleModelPath: String

  private var subscriptions = Set<AnyCancellable>()

  init(chatSourceType: ChatSourceType, exampleModelPath: String) {
    self.chatSourceType = chatSourceType
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

      do {
        try ModelUtils.validateModel(fileURL: URL(fileURLWithPath: modelPath))
      } catch {
        print(error)
        self.modelState = .invalidModel(getInvalidModelTypeReason(from: error))
        return
      }

      self.modelState = .valid

      do {
        self.modelSizePickerViewModel.modelSize = (try ModelUtils.getModelType(forFileAt: URL(fileURLWithPath: modelPath))).toModelSize()
      } catch {
        print(error)
      }
    }.store(in: &subscriptions)

    modelSizePickerViewModel.$modelSize.combineLatest($modelState)
      .map { modelSize, modelState -> Bool in
        return modelState.isValid && !modelSize.isUnknown
      }.sink { [weak self] isValid in
        self?.settingsValid.send(isValid)
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
