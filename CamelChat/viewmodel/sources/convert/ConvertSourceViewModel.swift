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

    var conversionSteps: [ConvertSourceStepViewModel]? {
      switch self {
      case .notStarted:
        return nil
      case .converting(steps: let steps):
        return steps
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

    let completionHandler: ConvertSourceStepViewModel.CompletionHandler = { [weak self] id, status in
      guard
        let self,
        status.isSuccess,
        let steps = self.state.conversionSteps,
        let stepIndex = steps.firstIndex(where: { $0.id == id })
      else { return }

      if stepIndex < steps.count - 1 {
        steps[stepIndex + 1].start()
      }
    }
    let steps = [
      ConvertSourceStepViewModel(label: "Checking environment", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return try await ModelConverter.canRunConversion(CommandConnectors(command: command, stdout: stdout, stderr: stderr)).exitCode
      }, completionHandler: completionHandler),
      ConvertSourceStepViewModel(label: "Installing dependencies", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return try await ModelConverter.installDependencies(CommandConnectors(command: command, stdout: stdout, stderr: stderr)).exitCode
      }, completionHandler: completionHandler),
      ConvertSourceStepViewModel(label: "Checking dependencies", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return try await ModelConverter.checkInstalledDependencies(CommandConnectors(command: command, stdout: stdout, stderr: stderr)).exitCode
      }, completionHandler: completionHandler),
      ConvertSourceStepViewModel(label: "Converting model", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return 0
      }, completionHandler: completionHandler),
      ConvertSourceStepViewModel(label: "Quantizing model", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return 0
      }, completionHandler: completionHandler)
    ]

    state = .converting(steps: steps)
    steps.first?.start()
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
