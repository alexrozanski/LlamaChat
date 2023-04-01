//
//  ConfigureLlamaSourceViewModel.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class ConfigureLlamaSourceViewModel: ObservableObject, ConfigureSourceViewModel {
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

  weak var setupViewModel: SetupViewModel?

  init(setupViewModel: SetupViewModel) {
    self.setupViewModel = setupViewModel
  }

  func validate() -> Bool {
    return modelPathState.isValid
  }

  func goBack() {
    setupViewModel?.goBack()
  }

  func addSource() {
    guard modelPathState.isValid else { return }

    setupViewModel?.add(source: ChatSource(name: "LLaMa", type: .llama, modelURL: URL(fileURLWithPath: modelPath)))
  }
}
