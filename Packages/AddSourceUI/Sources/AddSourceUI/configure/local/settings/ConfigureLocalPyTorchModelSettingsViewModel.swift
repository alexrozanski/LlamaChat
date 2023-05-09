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

  private(set) lazy var modelSizePickerViewModel = SizePickerViewModel(labelProvider: { modelSize, defaultProvider in
    return ""
//    switch modelSize {
//    case .unknown:
//      return "Select Model Size"
//    case .size7B, .size13B, .size30B, .size65B:
//      let numFiles = modelSize.requiredNumberOfModelFiles
//      return "\(defaultProvider(modelSize)) (\(numFiles) \(numFiles == 1 ? "file" : "files"))"
//    }
  })
  private(set) lazy var pathSelectorViewModel = PathSelectorViewModel(
    customLabel: "Model Directory",
    selectionMode: .directories
  )

  let sourceSettings = CurrentValueSubject<ConfiguredSourceSettings?, Never>(nil)

  private var subscriptions = Set<AnyCancellable>()

  init() {
    modelSizePickerViewModel
      .$modelSize
      .map { $0?.requiredNumberOfModelFiles ?? 0 }
      .assign(to: &$requiredNumberOfModelFiles)

//    modelSizePickerViewModel.$modelSize
//      .combineLatest($conversionState)
//      .map { modelSize, conversionState in
//        return !modelSize.isUnknown && conversionState.canConvert
//      }
//      .assign(to: &$showPathSelector)

    pathSelectorViewModel.$modelPaths
      .combineLatest(modelSizePickerViewModel.$modelSize)
      .sink { [weak self] modelPaths, modelSize in
//        guard let self else { return }
//
//        guard let modelPath = modelPaths.first else {
//          self.modelState = .none
//          return
//        }
//
//        let directoryURL = URL(fileURLWithPath: modelPath)
//        let data = ConvertPyTorchToGgmlConversionData(
//          modelType: modelSize.toModelType(),
//          directoryURL: directoryURL
//        )
//        switch ModelConverter.llamaFamily.validateConversionData(data, returning: &self.files) {
//        case .success(let validatedData):
//          self.modelState = .valid(data: validatedData)
//        case .failure(let error):
//          switch error {
//          case .missingFiles(let filenames):
//            self.modelState = .invalidModelDirectory(reason: .missingFiles(filenames.count))
//          }
//        }
      }.store(in: &subscriptions)

    $modelState
      .combineLatest(modelSizePickerViewModel.$modelSize)
      .sink { [weak self] modelState, modelSize in
//        guard !modelSize.isUnknown else {
//          self?.sourceSettings.send(nil)
//          return
//        }
//
//        switch modelState {
//        case .none:
//          self?.pathSelectorViewModel.errorMessage = nil
//          self?.sourceSettings.send(nil)
//        case .invalidModelDirectory(reason: let reason):
//          switch reason {
//          case .missingFiles(let count):
//            self?.pathSelectorViewModel.errorMessage = "Directory is missing \(count) \(count == 1 ? "file" : "files")"
//          }
//          self?.sourceSettings.send(nil)
//        case .valid(data: let validatedData):
//          self?.pathSelectorViewModel.errorMessage = nil
//          self?.sourceSettings.send(.pyTorchCheckpoints(data: validatedData))
//        }
      }.store(in: &subscriptions)
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
