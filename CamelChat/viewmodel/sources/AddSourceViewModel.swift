//
//  AddSourceViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation

enum AddSourceStep: Hashable {
  case configureSource(type: ChatSourceType)
  case convertPyTorchSource(type: ChatSourceType, modelDirectoryURL: URL, modelSize: ModelSize)
}

class AddSourceViewModel: ObservableObject {
  typealias CloseHandler = (_ newChatSource: ChatSource?) -> Void

  private let chatSources: ChatSources
  private let closeHandler: CloseHandler

  @Published var navigationPath = [AddSourceStep]()

  private(set) var configureSourceViewModel: ConfigureSourceViewModel?

  private(set) lazy var selectSourceTypeViewModel: SelectSourceTypeViewModel = {
    return SelectSourceTypeViewModel(chatSources: chatSources) { [weak self] sourceType in
      self?.configureSourceViewModel = self?.makeConfigureSourceViewModel(for: sourceType)
      self?.navigationPath.append(.configureSource(type: sourceType))
    }
  }()

  init(chatSources: ChatSources, closeHandler: @escaping CloseHandler) {
    self.chatSources = chatSources
    self.closeHandler = closeHandler
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
      case .pyTorchCheckpoints(directory: let directoryURL, modelSize: let modelSize):
        self?.navigationPath.append(.convertPyTorchSource(type: sourceType, modelDirectoryURL: directoryURL, modelSize: modelSize))
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
    chatSources.add(source: source)
    closeHandler(source)
  }
}
