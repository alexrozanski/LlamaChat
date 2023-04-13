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

func makeConfigureLocalGPT4AllModelSourceViewModel(
  nextHandler: @escaping ConfigureLocalModelSourceViewModel.NextHandler
) -> ConfigureLocalModelSourceViewModel {
  return ConfigureLocalModelSourceViewModel(
    defaultName: "GPT4All",
    chatSourceType: .gpt4All,
    exampleGgmlModelPath: "gpt4all-lora-quantized.bin",
    nextHandler: nextHandler
  )
}

@ViewBuilder func makeConfigureSourceView(from viewModel: ConfigureSourceViewModel) -> some View {
  if let viewModel = viewModel as? ConfigureLocalModelSourceViewModel {
    ConfigureLocalModelSourceView(viewModel: viewModel)
  }
}
