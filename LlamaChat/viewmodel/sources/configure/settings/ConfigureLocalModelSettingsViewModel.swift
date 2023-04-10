//
//  ConfigureLocalModelSettingsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import Combine
import llama

enum ConfigureLocalModelSourceType: String, Identifiable, CaseIterable {
  case pyTorch
  case ggml

  var id: String { return rawValue }  
}

enum SourceSettings {
  case ggmlModel(modelURL: URL, modelSize: ModelSize)
  case pyTorchCheckpoints(data: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>, modelSize: ModelSize)
}

protocol ConfigureLocalModelSettingsViewModel {
  var sourceType: ConfigureLocalModelSourceType { get }
  var modelSize: ModelSize? { get }

  var sourceSettings: CurrentValueSubject<SourceSettings?, Never> { get }
}
