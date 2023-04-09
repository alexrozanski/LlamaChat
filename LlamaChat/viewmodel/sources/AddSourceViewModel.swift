//
//  AddSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import llama

enum AddSourceStep: Hashable {
  case configureSource
  case convertPyTorchSource
}

class AddSourceViewModel: ObservableObject {
  typealias CloseHandler = (_ newChatSource: ChatSource?) -> Void

  private let chatSources: ChatSources
  private let closeHandler: CloseHandler

  @Published var navigationPath = [AddSourceStep]()

  private(set) lazy var selectSourceTypeViewModel: SelectSourceTypeViewModel = {
    return SelectSourceTypeViewModel(chatSources: chatSources) { [weak self] sourceType in
      self?.configureSourceViewModel = self?.makeConfigureSourceViewModel(for: sourceType)
      self?.navigationPath.append(.configureSource)
    }
  }()

  private(set) var configureSourceViewModel: ConfigureSourceViewModel?
  private(set) var convertSourceViewModel: ConvertSourceViewModel?

  private var addedModel = false

  init(chatSources: ChatSources, closeHandler: @escaping CloseHandler) {
    self.chatSources = chatSources
    self.closeHandler = closeHandler
  }

  deinit {
    if !addedModel {
      convertSourceViewModel?.cleanUp()
    }
  }

  private func makeConfigureSourceViewModel(for sourceType: ChatSourceType) -> ConfigureSourceViewModel {
    let nextHandler: ConfigureLocalModelSourceViewModel.NextHandler = { [weak self] configuredSource in
      switch configuredSource.settings {
      case .ggmlModel(modelURL: let modelURL, modelSize: let modelSize):
        let source = ChatSource(
          name: configuredSource.name,
          type: sourceType,
          modelURL: modelURL,
          modelSize: modelSize
        )
        self?.add(source: source)
      case .pyTorchCheckpoints(data: let validatedData):
        self?.convertSourceViewModel = ConvertSourceViewModel(
          data: validatedData,
          cancelHandler: { [weak self] in self?.closeHandler(nil) }
        )
        self?.navigationPath.append(.convertPyTorchSource)
      }
    }

    switch sourceType {
    case .llama:
      return makeConfigureLocalLlamaModelSourceViewModel(nextHandler: nextHandler)
    case .alpaca:
      return makeConfigureLocalAlpacaModelSourceViewModel(nextHandler:nextHandler)
    case .gpt4All:
      return makeConfigureLocalGPT4AllModelSourceViewModel(nextHandler:nextHandler)
    }
  }

  private func add(source: ChatSource) {
    guard !addedModel else { return }

    chatSources.add(source: source)
    addedModel = true
    closeHandler(source)
  }
}
