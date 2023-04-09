//
//  ConversionPipeline.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 09/04/2023.
//

import Foundation
import Combine

class ConversionPipeline: ObservableObject {
  typealias PipelineBuilder = () -> [ConvertStep]

  enum State {
    case notRunning
    case running
    case finished(success: Bool)

    var isRunning: Bool {
      switch self {
      case .notRunning, .finished: return false
      case .running: return true
      }
    }
  }

  @Published private(set) var state: State = .notRunning
  @Published private(set) var steps: [ConvertStep]

  private var currentStepStateCancellable: AnyCancellable?

  let pipelineBuilder: PipelineBuilder

  init(pipelineBuilder: @escaping PipelineBuilder) {
    self.pipelineBuilder = pipelineBuilder
    self.steps = pipelineBuilder()
  }

  deinit {

  }

  var canStart: Bool {
    switch state {
    case .notRunning: return true
    case .running, .finished: return false
    }
  }

  func run() {
    guard canStart, let first = steps.first else { return }

    run(step: first)
    state = .running
  }

  func stop() {}

  func restart() {
    guard !state.isRunning else { return }

    steps = pipelineBuilder()
    state = .notRunning
    run()
  }

  private func run(step: ConvertStep) {
    guard let stepIndex = steps.firstIndex(where: { $0 === step }) else { return }

    currentStepStateCancellable = step.$state
      .sink { [weak self] newState in
        self?.handleStepStateChange(forStepAtIndex: stepIndex, stepState: newState)
      }
    step.run()
  }

  private func handleStepStateChange(forStepAtIndex index: Int, stepState: ConvertStep.State) {
    switch stepState {
    case .notStarted, .running:
      break
    case .skipped:
      skipRemainingSteps(fromStepAtIndex: index + 1)
    case .finished(result: let result):
      if index < steps.count - 1 {
        if let statusCode = try? result.get(), statusCode.isSuccess {
          run(step: steps[index + 1])
        } else {
          skipRemainingSteps(fromStepAtIndex: index + 1)
        }
      } else {
        if let statusCode = try? result.get(), statusCode.isSuccess {
          state = .finished(success: true)
        } else {
          state = .finished(success: false)
        }
      }
    }
  }

  private func skipRemainingSteps(fromStepAtIndex index: Int) {
    if index < steps.count - 1 {
      for i in index..<steps.count - 1 {
        steps[i].skip()
      }
    }
    state = .finished(success: false)
  }
}
