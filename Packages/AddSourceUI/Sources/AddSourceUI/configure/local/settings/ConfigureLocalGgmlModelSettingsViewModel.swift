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
  private(set) lazy var variantPickerViewModel = VariantPickerViewModel(
    label: "Model Size",
    labelProvider: { variant in
      return variant?.name ?? "Unknown"
    },
    variants: model.variants
  )

  @Published private(set) var modelState: ModelState = .none

  var modelPath: String? { return pathSelectorViewModel.modelPaths.first }
  var modelSize: ModelParameterSize? { return nil } // return variantPickerViewModel.selectedModelSize }

  let model: Model
  let exampleModelPath: String

  private var subscriptions = Set<AnyCancellable>()

  init(model: Model, exampleModelPath: String) {
    self.model = model
    self.exampleModelPath = exampleModelPath

    pathSelectorViewModel.$modelPaths
      .map { modelPaths in
        guard let modelPath = modelPaths.first else {
          return .none
        }

        guard FileManager().fileExists(atPath: modelPath) else {
          return .invalidPath
        }

        let modelURL = URL(fileURLWithPath: modelPath)
        do {
          try ModelUtils.llamaFamily.validateModel(at: modelURL)
        } catch {
          print(error)
          return .invalidModel(getInvalidModelTypeReason(from: error))
        }

        return .valid(modelURL: modelURL)
      }
      .assign(to: &$modelState)

    $modelState
      .map { modelState -> ModelVariant? in
        switch modelState {
        case .none, .invalidModel, .invalidPath:
          return nil
        case .valid(modelURL: let modelURL):
          do {
            let modelCard = try ModelUtils.llamaFamily.getModelCard(forFileAt: modelURL)
            let parameters = modelCard?.parameters
            return model.variants.first { variant in
              return variant.parameters.map { modelParams in parameters.map { modelParams.equal(to: $0) } ?? false } ?? false
            }
          } catch {
            print(error)
            return nil
          }
        }
      }
      .assign(to: &variantPickerViewModel.$selectedVariant)

    $modelState
      .map { modelState in
        switch modelState {
        case .none, .valid:
          return nil
        case .invalidPath:
          return "Selected file is invalid"
        case .invalidModel(let reason):
          switch reason {
          case .unknown, .invalidFileType:
            return "Selected file is not a valid model"
          case .unsupportedModelVersion:
            return "Selected model is of an unsupported version"
          }
        }
      }
      .assign(to: &pathSelectorViewModel.$errorMessage)

    $modelState
      .map { modelState in
        switch modelState {
        case .none, .invalidModel, .invalidPath:
          return nil
        case .valid(modelURL: let modelURL):
          return .ggmlModel(modelURL: modelURL)
        }
      }
      .assign(to: \.value, on: sourceSettings)
      .store(in: &subscriptions)
  }
}

fileprivate extension ModelType {
  func toModelSize() -> ModelParameterSize? {
    switch self {
    case .unknown: return nil
    case .size7B: return .billions(Decimal(7))
    case .size13B: return .billions(Decimal(13))
    case .size30B: return .billions(Decimal(30))
    case .size65B: return .billions(Decimal(65))
    }
  }
}
