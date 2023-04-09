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
  private typealias ConvertPyTorchModelConversionPipeline = ModelConversionPipeline<
    ConvertPyTorchToGgmlConversionStep,
    ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>,
    ConvertPyTorchToGgmlConversionResult
  >
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
  @Published private var pipeline: ConvertPyTorchModelConversionPipeline
  @Published var conversionSteps: [ConvertSourceStepViewModel]

  private var subscriptions = Set<AnyCancellable>()

  private let data: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>
  private let cancelHandler: CancelHandler

  init(data: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>, cancelHandler: @escaping CancelHandler) {
    self.data = data
    self.pipeline = ModelConverter().makeConversionPipeline(with: data)
    self.cancelHandler = cancelHandler
    self.conversionSteps = []

    $pipeline.sink { [weak self] newPipeline in
      guard let self else { return }
      self.conversionSteps = self.pipeline.steps.map { ConvertSourceStepViewModel(conversionStep: $0) }
    }.store(in: &subscriptions)

    pipeline.$state
      .sink { [weak self] newState in
        switch newState {
        case .notRunning:
          self?.state = .notStarted
        case .running:
          self?.state = .converting
        case .failed:
          self?.state = .failedToConvert
        case .finished:
          self?.state = .finishedConverting
        }
      }.store(in: &subscriptions)
  }

  public func startConversion() {
    switch state {
    case .converting, .finishedConverting:
      return
    case .notStarted:
      state = .converting
      Task.init {
        try await pipeline.run(with: data)
      }
    case .failedToConvert:
      restartConversion()
    }
  }

  public func stopConversion() {
    guard state.isConverting else { return }
    pipeline.stop()
  }

  public func restartConversion() {
    pipeline = ModelConverter().makeConversionPipeline(with: data)
    state = .converting
    Task.init {
      try await pipeline.run(with: data)
    }
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
