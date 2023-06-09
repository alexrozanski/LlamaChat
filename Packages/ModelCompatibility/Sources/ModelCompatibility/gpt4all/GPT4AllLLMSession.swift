//
//  GPT4AllLLMSession.swift
//
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import CameLLM
import CameLLMGPTJ
import DataModel

final class GPT4AllLLMSession: LLMSession {
  weak var delegate: LLMSessionDelegate?

  private(set) var state: LLMSessionState = .notStarted
  private let _session: any Session<GPTJSessionState, GPTJPredictionState>

  init(session: any Session<GPTJSessionState, GPTJPredictionState>, delegate: LLMSessionDelegate) {
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

    return ConcreteSessionPredictionCancellable(cancellable: cancellable)
  }

  func currentContext() async throws -> LLMSessionContext? {
    return nil
  }
}

func makeGPT4AllLLMSession(
  for chatSource: ChatSource,
  modelParameters: GPT4AllModelParameters,
  numThreads: UInt,
  delegate: LLMSessionDelegate
) -> LLMSession {
  let config = SessionConfig.configurableDefaults()
    .withModelParameters(modelParameters)
    .build()
  return GPT4AllLLMSession(
    session: SessionManager.gpt4AllJ.makeSession(with: chatSource.modelURL, config: config),
    delegate: delegate
  )
}

fileprivate extension GPTJPredictionState {
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
  func withModelParameters(_ modelParameters: GPT4AllModelParameters) -> SessionConfigBuilder {
    return withNumTokens(modelParameters.numberOfTokens)
      .withHyperparameters { hyperparameters in
        hyperparameters
          .withBatchSize(modelParameters.batchSize)
          .withTopK(modelParameters.topK)
          .withTopP(modelParameters.topP)
          .withTemperature(modelParameters.temperature)
          .withRepeatPenalty(modelParameters.repeatPenalty)
      }
  }
}