//
//  ConfigureSourceViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI
import Combine
import CameLLM
import CameLLMLlama
import DataModel

struct ConfiguredSource {
  let name: String
  let avatarImageName: String?
  let settings: ConfiguredSourceSettings
}

enum ConfiguredSourceSettings {
  case ggmlModel(modelURL: URL)
  case pyTorchCheckpoints(data: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>)
  case downloadedFile(fileURL: URL)
}
