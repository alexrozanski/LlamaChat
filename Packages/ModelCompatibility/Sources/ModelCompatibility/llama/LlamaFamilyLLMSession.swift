//
//  LlamaFamilyLLMSession.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import CameLLM
import CameLLMLlama
import DataModel

final class LlamaFamilyLLMSession: LLMSession {
  weak var delegate: LLMSessionDelegate?

  private(set) var state: LLMSessionState = .notStarted
  private let _session: any Session<LlamaSessionState, LlamaPredictionState>

  init(session: any Session<LlamaSessionState, LlamaPredictionState>, delegate: LLMSessionDelegate) {
    _session = session
    self.delegate = delegate
  }

  func predict(with prompt: String, tokenHandler: @escaping (String) -> Void, stateChangeHandler: @escaping (LLMPredictionState) -> Void) -> LLMSessionPredictionCancellable {
    let cancellable = _session.predict(
      with: prompt,
      tokenHandler: tokenHandler,
      stateChangeHandler: { state in
        stateChangeHandler(state.toLLMPredictionState())
      },
      handlerQueue: .main
    )

    return LlamaFamilyPredictionCancellable(cancellable: cancellable)
  }

  func currentContext() async throws -> LLMSessionContext? {
    return nil
  }
}

func makeLlamaFamilyLLMSession(
  for chatSource: ChatSource,
  modelParameters: LlamaFamilyModelParameters,
  numThreads: UInt,
  delegate: LLMSessionDelegate
) -> LLMSession {
  let config = SessionConfig.configurableDefaults()
    .withModelParameters(
      modelParameters,
      numThreads: numThreads,
      keepModelInMemory: chatSource.useMlock
    )
    .build()

  return LlamaFamilyLLMSession(
    session: SessionManager.llamaFamily.makeSession(
      with: chatSource.modelURL,
      config: config
    ),
    delegate: delegate
  )
}

final class LlamaFamilyPredictionCancellable: LLMSessionPredictionCancellable {
  private let _cancellable: PredictionCancellable
  init(cancellable: PredictionCancellable) {
    _cancellable = cancellable
  }

  func cancel() {
    _cancellable.cancel()
  }
}

fileprivate extension LlamaPredictionState {
  func toLLMPredictionState() -> LLMPredictionState {
    switch self {
    case .notStarted:
      return .notStarted
    case .predicting:
      return .predicting
    case .cancelled:
      return .cancelled
    case .finished:
      return .finished
    case .error(let error):
      return .error(error)
    }
  }
}

fileprivate extension SessionConfigBuilder {
  func withModelParameters(
    _ modelParameters: LlamaFamilyModelParameters,
    numThreads: UInt,
    keepModelInMemory: Bool
  ) -> SessionConfigBuilder {
    return withSeed(modelParameters.seedValue)
      .withNumThreads(numThreads)
      .withNumTokens(modelParameters.numberOfTokens)
      .withKeepModelInMemory(keepModelInMemory)
      .withHyperparameters { hyperparameters in
        hyperparameters
          .withContextSize(modelParameters.contextSize)
          .withBatchSize(modelParameters.batchSize)
          .withLastNTokensToPenalize(modelParameters.lastNTokensToPenalize)
          .withTopK(modelParameters.topK)
          .withTopP(modelParameters.topP)
          .withTemperature(modelParameters.temperature)
          .withRepeatPenalty(modelParameters.repeatPenalty)
      }
  }
}

