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

  @Published var modelPath = "" {
    didSet {
      modelPathState = FileManager().fileExists(atPath: modelPath) ? .valid : .invalid
    }
  }
  @Published var canContinue: Bool = false

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
      navigationViewModel.canContinue = modelPathState.isValid
    }
  }

  let navigationViewModel: ConfigureSourceNavigationViewModel

  private let addSourceHandler: AddSourceHandler
  private let goBackHandler: GoBackHandler

  init(addSourceHandler: @escaping AddSourceHandler, goBackHandler: @escaping GoBackHandler) {
    self.addSourceHandler = addSourceHandler
    self.goBackHandler = goBackHandler
    navigationViewModel = ConfigureSourceNavigationViewModel()
    navigationViewModel.delegate = self
  }
}

extension ConfigureLocalModelSourceViewModel: ConfigureSourceNavigationViewModelDelegate {
  func goBack() {
    goBackHandler()
  }

  func next() {
    guard modelPathState.isValid else { return }
    addSourceHandler(ChatSource(name: "LLaMa", type: .llama, modelURL: URL(fileURLWithPath: modelPath)))
  }
}
