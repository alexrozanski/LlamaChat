//
//  ConfigureSourceViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI
import Combine

protocol ConfigureSourceViewModel {
  var chatSourceType: ChatSourceType { get }

  var primaryActionsViewModel: ConfigureSourcePrimaryActionsViewModel { get }
}

func makeConfigureLocalLlamaModelSourceViewModel(
  nextHandler: @escaping ConfigureLocalModelSourceViewModel.NextHandler
) -> ConfigureLocalModelSourceViewModel {
  return ConfigureLocalModelSourceViewModel(
    defaultName: "LLaMA",
    chatSourceType: .llama,
    exampleGgmlModelPath: "ggml-model-q4_0.bin",
    nextHandler: nextHandler
  )
}

func makeConfigureLocalAlpacaModelSourceViewModel(
  nextHandler: @escaping ConfigureLocalModelSourceViewModel.NextHandler
) -> ConfigureLocalModelSourceViewModel {
  return ConfigureLocalModelSourceViewModel(
    defaultName: "Alpaca",
    chatSourceType: .alpaca,
    exampleGgmlModelPath: "ggml-alpaca-7b-q4.bin",
    nextHandler: nextHandler
  )
}

func makeConfigureDownloadableGPT4AllModelSourceViewModel(
  nextHandler: @escaping ConfigureLocalModelSourceViewModel.NextHandler
) -> ConfigureDownloadableModelSourceViewModel {
  return ConfigureDownloadableModelSourceViewModel(
    chatSourceType: .gpt4All,
    nextHandler: nextHandler
  )
}

@ViewBuilder func makeConfigureSourceView(from viewModel: ConfigureSourceViewModel) -> some View {
  if let viewModel = viewModel as? ConfigureLocalModelSourceViewModel {
    ConfigureLocalModelSourceView(viewModel: viewModel)
  } else if let viewModel = viewModel as? ConfigureDownloadableModelSourceViewModel {
    ConfigureDownloadableModelSourceView(viewModel: viewModel)
  }
}
