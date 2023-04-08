//
//  ConvertSourceViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import Foundation
import Coquille
import llama

class ConvertSourceViewModel: ObservableObject {
  enum State {
    case notStarted
    case converting(steps: [ConvertSourceStepViewModel])

    var isInitial: Bool {
      switch self {
      case .notStarted:
        return true
      case .converting:
        return false
      }
    }

    var isConverting: Bool {
      switch self {
      case .notStarted:
        return false
      case .converting:
        return true
      }
    }
  }

  @Published private(set) var state: State = .notStarted

  let sourceType: ChatSourceType
  let modelDirectoryURL: URL
  let modelSize: ModelSize

  init(sourceType: ChatSourceType, modelDirectoryURL: URL, modelSize: ModelSize) {
    self.sourceType = sourceType
    self.modelDirectoryURL = modelDirectoryURL
    self.modelSize = modelSize
  }

  public func startConversion() {
    guard state.isInitial else { return }

    state = .converting(steps: [
      ConvertSourceStepViewModel(label: "Checking environment", executionHandler: { command, stdout, stderr, exitCode in
        return try await ModelConverter.canRunConversion(CommandConnectors(command: command, stdout: stdout, stderr: stderr, exitCode: exitCode))
      }),
      ConvertSourceStepViewModel(label: "Installing dependencies", executionHandler: { command, stdout, stderr, exitCode in
        return try await ModelConverter.installDependencies(CommandConnectors(command: command, stdout: stdout, stderr: stderr, exitCode: exitCode))
      }),
      ConvertSourceStepViewModel(label: "Checking dependencies", executionHandler: { command, stdout, stderr, exitCode in
        return try await ModelConverter.checkInstalledDependencies(CommandConnectors(command: command, stdout: stdout, stderr: stderr, exitCode: exitCode))
      }),
      ConvertSourceStepViewModel(label: "Converting model", executionHandler: { command, stdout, stderr, exitCode in
        return true
      }),
      ConvertSourceStepViewModel(label: "Quantizing model", executionHandler: { command, stdout, stderr, exitCode in
        return true
      })
    ])
  }

  public func stopConversion() {
    guard state.isConverting else { return }

    state = .notStarted
  }
}

private extension Coquille.Process.Status {
  func toExitCode() -> Int32 {
    switch self {
    case .success:
      return 0
    case .failure(let code):
      return code
    }
  }
}
