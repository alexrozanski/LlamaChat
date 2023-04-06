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

protocol ConfigureLocalModelSettingsViewModel {
  var sourceType: ConfigureLocalModelSourceType { get }

  // Should be a ggml model path
  var modelPath: String? { get }
  var modelSize: ModelSize? { get }

  var settingsValid: CurrentValueSubject<Bool, Never> { get }
}
