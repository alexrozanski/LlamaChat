//
//  ConfigureLocalPyTorchModelSettingsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import Combine
import CameLLM
import CameLLMLlama
import DataModel

class ConfigureLocalPyTorchModelSettingsViewModel: ObservableObject, ConfigureLocalModelSettingsViewModel {
  var sourceType: ConfigureLocalModelSourceType {
    return .pyTorch
  }

  var modelPath: String? { return nil }
  var modelSize: ModelSize? {
    return nil
//    return variantPickerViewModel.selectedModelSize
  }

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

  enum InvalidModelDirectoryReason {
    case missingFiles(_ count: Int)
  }

  enum ModelState {
    case none
    case invalidModelDirectory(reason: InvalidModelDirectoryReason)
    case valid(data: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>)
  }

  @Published private(set) var modelState: ModelState = .none

  @Published var conversionState: ConversionState = .unknown
  @Published var files: [ModelConversionFile]? = nil

  let sourceSettings = CurrentValueSubject<ConfiguredSourceSettings?, Never>(nil)

  private(set) lazy var variantPickerViewModel = VariantPickerViewModel(
    label: "Model Size",
    labelProvider: { variant in
      guard let variant else {
        return "Select Model Size"
      }

      guard let numFiles = requiredNumberOfModelFiles(for: variant) else {
        return variant.name
      }

      return "\(variant.name) (\(numFiles) \(numFiles == 1 ? "file" : "files"))"
    },
    variants: model.variants
  )
  private(set) lazy var pathSelectorViewModel = PathSelectorViewModel(
    customLabel: "Model Directory",
    selectionMode: .directories
  )

  private var subscriptions = Set<AnyCancellable>()

  private let model: Model

  init(model: Model) {
    self.model = model

    variantPickerViewModel.$selectedVariant
      .combineLatest($conversionState)
      .map { variant, conversionState in
        return variant != nil && conversionState.canConvert
      }
      .assign(to: &$showPathSelector)

    pathSelectorViewModel.$modelPaths
      .combineLatest(variantPickerViewModel.$selectedVariant)
      .map { [weak self] modelPaths, variant in
        guard let self, let modelPath = modelPaths.first, let variant, let modelType = modelType(from: variant) else {
          return .none
        }

        let directoryURL = URL(fileURLWithPath: modelPath)
        let data = ConvertPyTorchToGgmlConversionData(
          modelType: modelType,
          directoryURL: directoryURL
        )
        switch ModelConverter.llamaFamily.validateConversionData(data, returning: &self.files) {
        case .success(let validatedData):
          return .valid(data: validatedData)
        case .failure(let error):
          switch error {
          case .missingFiles(let filenames):
            return .invalidModelDirectory(reason: .missingFiles(filenames.count))
          }
        }
      }.assign(to: &$modelState)

    $modelState
      .map { modelState in
        switch modelState {
        case .none, .valid:
            return nil
        case .invalidModelDirectory(reason: let reason):
          switch reason {
          case .missingFiles(let count):
            return "Directory is missing \(count) \(count == 1 ? "file" : "files")"
          }
        }
      }
      .assign(to: &pathSelectorViewModel.$errorMessage)

    $modelState
      .map { modelState in
        switch modelState {
        case .none, .invalidModelDirectory:
          return nil
        case .valid(data: let validatedData):
          return .pyTorchCheckpoints(data: validatedData)
        }
      }
      .assign(to: \.value, on: sourceSettings)
      .store(in: &subscriptions)
  }

  func determineConversionStateIfNeeded() {
    guard conversionState.isUnknown else { return }

    conversionState = .loading
    Task.init {
      do {
        let canConvert = (try await ModelConverter.llamaFamily.canRunConversion())
        await MainActor.run {
          conversionState = .canConvert(canConvert)
        }
      } catch {
        print("Error determining model conversion status", error)
      }
    }
  }
}

fileprivate func modelType(from variant: ModelVariant) -> ModelType? {
  guard
    let parametersString = variant.parameters,
    let parameters = ParameterSize.from(string: parametersString)
  else { return nil }

  return ModelType.from(parameters: parameters)
}

fileprivate func requiredNumberOfModelFiles(for variant: ModelVariant) -> Int? {
  return modelType(from: variant)?.numPyTorchModelParts
}

fileprivate extension ModelSize {
  var requiredNumberOfModelFiles: Int {
    return 0
//    switch self {
//    case .unknown: return 0
//    case .size7B: return 1
//    case .size13B: return 2
//    case .size30B: return 4
//    case .size65B: return 8
//    }
  }

  func toModelType() -> ModelType {
    return .unknown
//    switch self {
//    case .unknown: return .unknown
//    case .size7B: return .size7B
//    case .size13B: return .size13B
//    case .size30B: return .size30B
//    case .size65B: return .size65B
//    }
  }
}
