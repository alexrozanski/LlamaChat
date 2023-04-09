//
//  ConvertSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import Foundation
import Combine
import Coquille
import llama

class ConvertSourceViewModel: ObservableObject {
  typealias CancelHandler = () -> Void

  enum State {
    case notStarted
    case converting
    case finishedConverting
    case failedToConvert

    var isConverting: Bool {
      switch self {
      case .notStarted, .finishedConverting, .failedToConvert: return false
      case .converting: return true
      }
    }

    var isFinished: Bool {
      switch self {
      case .notStarted, .converting: return false
      case .finishedConverting, .failedToConvert: return true
      }
    }

    var finishedSuccessfully: Bool {
      switch self {
      case .notStarted, .converting, .failedToConvert: return false
      case .finishedConverting: return true
      }
    }

    var startedConverting: Bool {
      switch self {
      case .notStarted: return false
      case .converting, .finishedConverting, .failedToConvert: return true
      }
    }
  }

  @Published private(set) var state: State = .notStarted
  @Published var conversionSteps: [ConvertSourceStepViewModel]

  private var subscriptions = Set<AnyCancellable>()

  private let pipeline: ConversionPipeline
  private let cancelHandler: CancelHandler

  init(pipeline: ConversionPipeline, cancelHandler: @escaping CancelHandler) {
    self.pipeline = pipeline
    self.cancelHandler = cancelHandler
    self.conversionSteps = pipeline.steps.map { ConvertSourceStepViewModel(convertStep: $0) }

    pipeline.$state
      .sink { [weak self] newState in
        switch newState {
        case .notRunning:
          self?.state = .notStarted
        case .running:
          self?.state = .converting
        case .finished(let success):
          self?.state = success ? .finishedConverting : .failedToConvert
        }
      }.store(in: &subscriptions)
    pipeline.$steps.sink { [weak self] newSteps in
      self?.conversionSteps = newSteps.map { ConvertSourceStepViewModel(convertStep: $0) }
    }.store(in: &subscriptions)
  }

  public func startConversion() {
    pipeline.run()
  }

  public func stopConversion() {
    guard state.isConverting else { return }
    pipeline.stop()
  }

  public func restartConversion() {
    pipeline.restart()
  }

  public func cancel() {
    cancelHandler()
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

private func withCommandConnectors(
  _ handler: @escaping (CommandConnectors) async throws -> Int32
) -> ConvertStep.ExecutionHandler {
  return { command, stdout, stderr in
    let commandConnectors = CommandConnectors(command: command, stdout: stdout, stderr: stderr)
    return try await handler(commandConnectors)
  }
}
