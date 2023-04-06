//
//  AddSourceViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation

enum AddSourceStep: Hashable {
  case configureSource
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
      self?.navigationPath.append(.configureSource)
    }
  }()

  init(chatSources: ChatSources, closeHandler: @escaping CloseHandler) {
    self.chatSources = chatSources
    self.closeHandler = closeHandler
  }

  private func makeConfigureSourceViewModel(for sourceType: ChatSourceType) -> ConfigureSourceViewModel {
    switch sourceType {
    case .llama:
      return makeConfigureLocalLlamaModelSourceViewModel(
        addSourceHandler: { [weak self] source in
          self?.add(source: source)
        }
      )
    case .alpaca:
      return makeConfigureLocalAlpacaModelSourceViewModel(
        addSourceHandler:{ [weak self] source in
          self?.add(source: source)
        }
      )
    case .gpt4All:
      return makeConfigureLocalGPT4AllModelSourceViewModel(
        addSourceHandler:{ [weak self] source in
          self?.add(source: source)
        }
      )
    }
  }

  private func add(source: ChatSource) {
    chatSources.add(source: source)
    closeHandler(source)
  }
}
