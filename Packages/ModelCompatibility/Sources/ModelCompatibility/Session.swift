//
//  Session.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import DataModel
import CameLLM
import CameLLMLlama

public func makeSession(
  for source: ChatSource,
  numThreads: UInt
) -> any Session<LlamaSessionState, LlamaPredictionState> {
  let config: SessionConfig
  if let modelParameters = source.modelParameters?.wrapped as? LlamaFamilyModelParameters {
    config = SessionConfig.configurableDefaults()
      .withModelParameters(
        modelParameters,
        numThreads: numThreads,
        keepModelInMemory: source.useMlock
      )
      .build()
  } else {
    config = SessionConfig.defaults
  }

  return SessionManager.llamaFamily.makeSession(
    with: source.modelURL,
    config: config
  )
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
