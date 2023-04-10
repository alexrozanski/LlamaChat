//
//  ConfigureSourceViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI
import Combine

protocol ConfigureSourceNavigationViewModelDelegate: AnyObject {
  func next()
}

class ConfigureSourceNavigationViewModel: ObservableObject {
  @Published var showContinueButton: Bool = false
  @Published var canContinue: Bool = false
  @Published var nextButtonTitle: String = "Add"

  weak var delegate: ConfigureSourceNavigationViewModelDelegate?

  func next() {
    delegate?.next()
  }
}

struct ConfigureSourceNavigationView: View {
  @ObservedObject var viewModel: ConfigureSourceNavigationViewModel

  var body: some View {
    HStack {
      Spacer()
      if viewModel.showContinueButton {
        Button(viewModel.nextButtonTitle) {
          viewModel.next()
        }
        .keyboardShortcut(.return)
        .disabled(!viewModel.canContinue)
      }
    }
  }
}

protocol ConfigureSourceViewModel {
  var chatSourceType: ChatSourceType { get }

  var navigationViewModel: ConfigureSourceNavigationViewModel { get }
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
  VStack {
    if let viewModel = viewModel as? ConfigureLocalModelSourceViewModel {
      ConfigureLocalModelSourceView(viewModel: viewModel)
    } else {
      EmptyView()
    }
    Spacer()
    ConfigureSourceNavigationView(viewModel: viewModel.navigationViewModel)
      .padding()
  }
}
