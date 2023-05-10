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
  let model: Model
  let settings: ConfiguredSourceSettings
}

enum ConfiguredSourceSettings {
  case ggmlModel(modelURL: URL, variant: ModelVariant?)
  case pyTorchCheckpoints(data: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>, variant: ModelVariant?)
  case downloadedFile(fileURL: URL, variant: ModelVariant?)
}
