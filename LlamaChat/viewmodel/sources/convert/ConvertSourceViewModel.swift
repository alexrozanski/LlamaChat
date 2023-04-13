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

    $pipeline.sink { [weak self] newPipeline in
      guard let self else { return }
      self.conversionSteps = newPipeline.steps.map { ConvertSourceStepViewModel(conversionStep: $0) }
    }.store(in: &subscriptions)

    $pipeline
      .map { $0.$state }
      .switchToLatest()
      .scan(ConvertPyTorchModelConversionPipeline.State.notRunning, { oldState, newState in
        switch newState {
        case .notRunning, .running, .cancelled, .failed:
          switch oldState {
          case .finished(result: let result):
            // Capture self explicitly so that we clean up even if we have been deallocated.
            self.cleanUp(with: result)
          case .notRunning, .running, .cancelled, .failed:
            break
          }
        case .finished:
          break
        }
        return newState
      })
      .sink { [weak self] newState in
        switch newState {
        case .notRunning:
          self?.state = .notStarted
        case .running:
          self?.state = .converting
        case .failed, .cancelled:
          self?.state = .failedToConvert
        case .finished(result: let result):
          self?.state = .finishedConverting(result: result)
        }
      }.store(in: &subscriptions)

    $modelDirectory
      .scan(ModelDirectory?.none) { oldModelDirectory, newModelDirectory in
        // Make sure we don't accidentally delete the directory if we have already finished.
        if !self.hasFinished {
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
      cleanUp(with: result)
    }
    modelDirectory?.cleanUp()
    modelDirectory = nil
  }

  private func cleanUp(with result: ConvertPyTorchToGgmlConversionResult) {
    do {
      try result.cleanUp()
    } catch {
      print("WARNING: Failed to clean up converted GGML model")
    }
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
