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

  let validatedData: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>
  init(validatedData: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>) {
    self.validatedData = validatedData
  }

  public func startConversion() {
    guard state.isInitial else { return }

    let completionHandler: ConvertSourceStepViewModel.CompletionHandler = { [weak self] id, status in
      guard
        let self,
        let steps = self.state.conversionSteps,
        let stepIndex = steps.firstIndex(where: { $0.id == id })
      else { return }

      if stepIndex < steps.count - 1 {
        if status.isSuccess {
          steps[stepIndex + 1].start()
        } else {
          steps[stepIndex + 1].skip()
        }
      }
    }

    let validatedData = self.validatedData
    let modelConverter = ModelConverter()
    let steps = [
      ConvertSourceStepViewModel(label: "Checking environment", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return try await modelConverter.canRunConversion(CommandConnectors(command: command, stdout: stdout, stderr: stderr)).exitCode
      }, completionHandler: completionHandler),
      ConvertSourceStepViewModel(label: "Installing dependencies", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return try await modelConverter.installDependencies(CommandConnectors(command: command, stdout: stdout, stderr: stderr)).exitCode
      }, completionHandler: completionHandler),
      ConvertSourceStepViewModel(label: "Checking dependencies", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return try await modelConverter.checkInstalledDependencies(CommandConnectors(command: command, stdout: stdout, stderr: stderr)).exitCode
      }, completionHandler: completionHandler),
      ConvertSourceStepViewModel(label: "Converting model", convertSourceViewModel: self, executionHandler: { command, stdout, stderr in
        return try await modelConverter.convert(with: validatedData, commandConnectors: CommandConnectors(command: command, stdout: stdout, stderr: stderr)).exitCode
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
