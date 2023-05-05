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
  case ggmlModel(modelURL: URL, modelSize: ModelSize)
  case pyTorchCheckpoints(data: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>, modelSize: ModelSize)
  case downloadedFile(fileURL: URL, modelSize: ModelSize)
}

typealias ConfigureSourceNextHandler = (ConfiguredSource) -> Void

protocol ConfigureSourceViewModel {
  var chatSourceType: ChatSourceType { get }
  var primaryActionsViewModel: ConfigureSourcePrimaryActionsViewModel { get }
}

@ViewBuilder func makeConfigureSourceView(from viewModel: any ConfigureSourceViewModel) -> some View {
  if let viewModel = viewModel as? ConfigureLocalModelSourceViewModel {
    ConfigureLocalModelSourceView(viewModel: viewModel)
  } else if let viewModel = viewModel as? ConfigureDownloadableModelSourceViewModel {
    ConfigureDownloadableModelSourceView(viewModel: viewModel)
  }
}
