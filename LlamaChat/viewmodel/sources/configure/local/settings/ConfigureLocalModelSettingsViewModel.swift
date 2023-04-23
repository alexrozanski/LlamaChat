//
//  ConfigureLocalModelSettingsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import Combine
import CameLLM
import CameLLMLlama

enum ConfigureLocalModelSourceType: String, Identifiable, CaseIterable {
  case pyTorch
  case ggml

  var id: String { return rawValue }  
}

protocol ConfigureLocalModelSettingsViewModel {
  var sourceType: ConfigureLocalModelSourceType { get }
  var modelSize: ModelSize? { get }

  var sourceSettings: CurrentValueSubject<ConfiguredSourceSettings?, Never> { get }
}
