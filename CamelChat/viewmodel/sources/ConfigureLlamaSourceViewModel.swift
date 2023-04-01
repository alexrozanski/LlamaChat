//
//  ConfigureLlamaSourceViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class ConfigureLlamaSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  typealias AddSourceHandler = (ChatSource) -> Void
  typealias GoBackHandler = () -> Void

  @Published var modelPath = "" {
    didSet {
      modelPathState = FileManager().fileExists(atPath: modelPath) ? .valid : .invalid
    }
  }

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

  @Published private(set) var modelPathState: ModelPathState = .none

  private let addSourceHandler: AddSourceHandler
  private let goBackHandler: GoBackHandler

  init(addSourceHandler: @escaping AddSourceHandler, goBackHandler: @escaping GoBackHandler) {
    self.addSourceHandler = addSourceHandler
    self.goBackHandler = goBackHandler
  }

  func validate() -> Bool {
    return modelPathState.isValid
  }

  func goBack() {
    goBackHandler()
  }

  func addSource() {
    guard modelPathState.isValid else { return }
    addSourceHandler(ChatSource(name: "LLaMa", type: .llama, modelURL: URL(fileURLWithPath: modelPath)))
  }
}
