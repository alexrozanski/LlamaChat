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
    ConvertPyTorchToGgmlConversionPipelineInput,
    ConvertPyTorchToGgmlConversionResult
  >
  typealias CompletionHandler = (_ modelURL: URL, _ modelDirectory: ModelDirectory) -> Void
  typealias CancelHandler = () -> Void

  enum State {
    case notStarted
    case converting
    case finishedConverting(result: ConvertPyTorchToGgmlConversionResult)
    case failedToConvert

    var isConverting: Bool {
      switch self {
      case .notStarted, .finishedConverting, .failedToConvert: return false
      case .converting: return true
      }
    }

    var isFinishedConverting: Bool {
      switch self {
      case .notStarted, .converting: return false
      case .finishedConverting, .failedToConvert: return true
      }
    }

    var result: ConvertPyTorchToGgmlConversionResult? {
      switch self {
      case .notStarted, .converting, .failedToConvert:
        return nil
      case .finishedConverting(result: let result):
        return result
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
  private let completionHandler: CompletionHandler
  private let cancelHandler: CancelHandler

  @Published private var modelDirectory: ModelDirectory?

  private var hasFinished = false

  init(
    data: ValidatedModelConversionData<ConvertPyTorchToGgmlConversionData>,
    completionHandler: @escaping CompletionHandler,
    cancelHandler: @escaping CancelHandler
  ) {
    self.data = data
    self.pipeline = ModelConverter().makeConversionPipeline()
    self.completionHandler = completionHandler
    self.cancelHandler = cancelHandler
    self.conversionSteps = []

    $pipeline
      .map { newPipeline in
        newPipeline.steps.map { ConvertSourceStepViewModel(conversionStep: $0) }
      }
      .assign(to: &$conversionSteps)

    $pipeline
      .map { $0.$state }
      .switchToLatest()
      .scan(ConvertPyTorchModelConversionPipeline.State.notRunning, { oldState, newState in
        switch newState {
        case .notRunning, .running, .cancelled, .failed:
          switch oldState {
          case .finished(result: let result):
            do {
              try result.cleanUp()
            } catch {
              print("WARNING: Failed to clean up converted GGML model")
            }
          case .notRunning, .running, .cancelled, .failed:
            break
          }
        case .finished:
          break
        }
        return newState
      })
      .map { newState in
        switch newState {
        case .notRunning:
          return State.notStarted
        case .running:
          return State.converting
        case .failed, .cancelled:
          return State.failedToConvert
        case .finished(result: let result):
          return State.finishedConverting(result: result)
        }
      }.assign(to: &$state)

    $modelDirectory
      .scan(ModelDirectory?.none) { [weak self] oldModelDirectory, newModelDirectory in
        // Make sure we don't accidentally delete the directory if we have already finished.
        if !(self?.hasFinished ?? false) {
          oldModelDirectory?.cleanUp()
        }
        return newModelDirectory
      }.sink { _ in }.store(in: &subscriptions)
  }

  func startConversion() {
    guard !state.startedConverting else { return }

    state = .converting

    do {
      let modelDirectory = try ModelFileManager().makeNewModelDirectory()
      self.modelDirectory = modelDirectory

      Task.init {
        try await pipeline.run(
          with: ConvertPyTorchToGgmlConversionPipelineInput(
            data: data,
            conversionBehavior: modelDirectory.map { .inOtherDirectory($0.url) } ?? .alongsideInputFile
          )
        )
      }
    } catch {
      state = .failedToConvert
    }
  }

  func stopConversion() {
    guard state.isConverting else { return }
    pipeline.stop()
  }

  func retryConversion() {
    pipeline = ModelConverter().makeConversionPipeline()
    state = .notStarted
    startConversion()
  }

  func finish() {
    guard let result = state.result, let modelDirectory, !hasFinished else { return }

    completionHandler(result.outputFileURL, modelDirectory)
    hasFinished = true
  }

  // Cleans up the converted model files :)
  func cleanUp_DANGEROUS() {
    switch state {
    case .notStarted, .converting, .failedToConvert:
      break
    case .finishedConverting(result: let result):
      do {
        try result.cleanUp()
      } catch {
        print("WARNING: Failed to clean up converted GGML model")
      }
    }
    modelDirectory?.cleanUp()
    modelDirectory = nil
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
