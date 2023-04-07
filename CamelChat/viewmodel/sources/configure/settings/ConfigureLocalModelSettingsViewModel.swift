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

enum SourceSettings: Equatable, Hashable {
  case ggmlModel(modelURL: URL, modelSize: ModelSize)
  case pyTorchCheckpoints(directory: URL, modelSize: ModelSize)
}

protocol ConfigureLocalModelSettingsViewModel {
  var sourceType: ConfigureLocalModelSourceType { get }
  var modelSize: ModelSize? { get }

  var sourceSettings: CurrentValueSubject<SourceSettings?, Never> { get }
}
