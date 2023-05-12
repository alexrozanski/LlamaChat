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
import CameLLMGPTJ
import DataModel
import ModelCompatibility
import ModelMetadata

class ConfigureLocalGgmlModelSettingsViewModel: ObservableObject, ConfigureLocalModelSettingsViewModel {
  enum ModelState {
    case none
    case invalidPath
    case invalidModel
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

  var showVariantPicker: Bool {
    return modelVariant == nil
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
  let modelVariant: ModelVariant?

  private var subscriptions = Set<AnyCancellable>()

  init(model: Model, modelVariant: ModelVariant?) {
    self.model = model
    self.modelVariant = modelVariant

    pathSelectorViewModel.$modelPaths
      .map { modelPaths in
        guard let modelPath = modelPaths.first else {
          return .none
        }

        guard FileManager().fileExists(atPath: modelPath) else {
          return .invalidPath
        }

        let modelURL = URL(fileURLWithPath: modelPath)
        if !validateModelFile(at: modelURL, model: model) {
          return .invalidModel
        }
        return .valid(modelURL: modelURL)
      }
      .assign(to: &$modelState)

    $modelState
      .map { [weak self] modelState -> ModelVariant? in
        guard let self, self.modelVariant == nil else { return nil }

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
        case .invalidModel:
          return "Selected model is not valid or unsupported"
        }
      }
      .assign(to: &pathSelectorViewModel.$errorMessage)

    $modelState
      .combineLatest(variantPickerViewModel.$selectedVariant)
      .map { modelState, selectedVariant in
        switch modelState {
        case .none, .invalidModel, .invalidPath:
          return nil
        case .valid(modelURL: let modelURL):
          return .ggmlModel(modelURL: modelURL, variant: modelVariant ?? selectedVariant)
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
