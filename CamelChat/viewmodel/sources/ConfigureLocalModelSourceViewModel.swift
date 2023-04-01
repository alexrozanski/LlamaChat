//
//  ConfigureLocalModelSourceViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation

class ConfigureLocalModelSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  typealias AddSourceHandler = (ChatSource) -> Void
  typealias GoBackHandler = () -> Void

  @Published var name: String {
    didSet {
      validate()
    }
  }
  @Published var modelPath = "" {
    didSet {
      modelPathState = FileManager().fileExists(atPath: modelPath) ? .valid : .invalid
    }
  }
  @Published var canContinue: Bool = false

  var modelType: String {
    switch chatSourceType {
    case .llama:
      return "LLaMa"
    case .alpaca:
      return "Alpaca"
    }
  }
  var exampleModelPath: String

  enum ModelPathState {
    case none
    case valid
    case invalid

    var isValid: Bool {
      switch self {
      case .none, .invalid:
        return false
      case .valid:
        return true
      }
    }
  }

  @Published private(set) var modelPathState: ModelPathState = .none {
    didSet {
      validate()
    }
  }

  let navigationViewModel: ConfigureSourceNavigationViewModel

  private let chatSourceType: ChatSourceType
  private let addSourceHandler: AddSourceHandler
  private let goBackHandler: GoBackHandler

  init(
    defaultName: String? = nil,
    chatSourceType: ChatSourceType,
    exampleModelPath: String,
    addSourceHandler: @escaping AddSourceHandler,
    goBackHandler: @escaping GoBackHandler
  ) {
    self.name = defaultName ?? ""
    self.chatSourceType = chatSourceType
    self.exampleModelPath = exampleModelPath
    self.addSourceHandler = addSourceHandler
    self.goBackHandler = goBackHandler
    navigationViewModel = ConfigureSourceNavigationViewModel()
    navigationViewModel.delegate = self
  }

  private func validate() {
    navigationViewModel.canContinue = modelPathState.isValid && !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }
}

extension ConfigureLocalModelSourceViewModel: ConfigureSourceNavigationViewModelDelegate {
  func goBack() {
    goBackHandler()
  }

  func next() {
    guard modelPathState.isValid else { return }
    addSourceHandler(ChatSource(name: name, type: chatSourceType, modelURL: URL(fileURLWithPath: modelPath)))
  }
}
