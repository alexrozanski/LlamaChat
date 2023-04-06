//
//  ConfigureLocalModelSettingsViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import Combine

enum ConfigureLocalModelSourceType: String, Identifiable, CaseIterable {
  case pyTorch
  case ggml

  var id: String { return rawValue }  
}

enum ConfigureLocalModelInvalidModelTypeReason {
  case unknown
  case invalidFileType
  case unsupportedModelVersion
}

enum ConfigureLocalModelState {
  case none
  case invalidPath
  case invalidModel(_ reason: ConfigureLocalModelInvalidModelTypeReason)
  case valid

  var isValid: Bool {
    switch self {
    case .none, .invalidPath, .invalidModel:
      return false
    case .valid:
      return true
    }
  }
}

protocol ConfigureLocalModelSettingsViewModel {
  var sourceType: ConfigureLocalModelSourceType { get }

  // Should be a ggml model path
  var modelPath: String? { get }
  var modelSize: ModelSize? { get }

  var settingsValid: CurrentValueSubject<Bool, Never> { get }
}
