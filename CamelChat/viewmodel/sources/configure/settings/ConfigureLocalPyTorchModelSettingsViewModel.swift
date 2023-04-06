//
//  ConfigureLocalGgmlModelSettingsViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import Combine

class ConfigureLocalPyTorchModelSettingsViewModel: ObservableObject, ConfigureLocalModelSettingsViewModel {
  var sourceType: ConfigureLocalModelSourceType {
    return .pyTorch
  }

  @Published private(set) var modelState: ConfigureLocalModelState = .none

  var modelPath: String? { return nil }
  var modelSize: ModelSize? {
    return modelSizePickerViewModel.modelSize
  }

  @Published private(set) var requiredNumberOfModelFiles = 1
  @Published private(set) var showPathSelector = false

  private(set) lazy var modelSizePickerViewModel = ConfigureLocalModelSizePickerViewModel(labelProvider: { modelSize, defaultProvider in
    switch modelSize {
    case .unknown:
      return "Select Model Size"
    case .size7B, .size13B, .size30B, .size65B:
      let numFiles = modelSize.requiredNumberOfModelFiles
      return "\(defaultProvider(modelSize)) (\(numFiles) \(numFiles == 1 ? "file" : "files"))"
    }
  })
  private(set) lazy var pathSelectorViewModel = ConfigureLocalModelPathSelectorViewModel()

  let chatSourceType: ChatSourceType
  let settingsValid = CurrentValueSubject<Bool, Never>(false)

  private var subscriptions = Set<AnyCancellable>()

  init(chatSourceType: ChatSourceType) {
    self.chatSourceType = chatSourceType
    modelSizePickerViewModel.$modelSize.sink { [weak self] newModelSize in
      guard let self else { return }

      self.showPathSelector = !newModelSize.isUnknown
      self.requiredNumberOfModelFiles = newModelSize.requiredNumberOfModelFiles
    }.store(in: &subscriptions)
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
}
