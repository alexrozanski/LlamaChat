//
//  ModelParameterUtils.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import Foundation
import llama

private let minimumContextSize = UInt(512)

func defaultModelParameters(for chatSourceType: ChatSourceType) -> ModelParameters {
  switch chatSourceType {
  case .llama:
    return ModelParameters.from(
      sessionConfig: LlamaSessionConfig.configurableDefaults
        .withHyperparameters { hyperparameters in
          hyperparameters.withContextSize(hyperparameters.contextSize.map { max($0, minimumContextSize) })
        }
        .build()
    )
  case .alpaca:
    return ModelParameters.from(
      sessionConfig: AlpacaSessionConfig.configurableDefaults
        .withHyperparameters { hyperparameters in
          hyperparameters.withContextSize(hyperparameters.contextSize.map { max($0, minimumContextSize) })
        }
        .build()
    )
  case .gpt4All:
    return ModelParameters.from(
      sessionConfig: GPT4AllSessionConfig.configurableDefaults
        .withHyperparameters { hyperparameters in
          hyperparameters.withContextSize(hyperparameters.contextSize.map { max($0, minimumContextSize) })
        }
        .build()
    )
  }
}

fileprivate extension ModelParameters {
  static func from(sessionConfig: SessionConfig) -> ModelParameters {
    return ModelParameters(
      seedValue: sessionConfig.seed,
      contextSize: sessionConfig.hyperparameters.contextSize,
      numberOfTokens: sessionConfig.numTokens,
      topP: sessionConfig.hyperparameters.topP,
      topK: sessionConfig.hyperparameters.topK,
      temperature: sessionConfig.hyperparameters.temperature,
      batchSize: sessionConfig.hyperparameters.batchSize,
      lastNTokensToPenalize: sessionConfig.hyperparameters.lastNTokensToPenalize,
      repeatPenalty: sessionConfig.hyperparameters.repeatPenalty
    )
  }
}
