//
//  ModelParameterUtils.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import Foundation
import CameLLM
import CameLLMLlama
import DataModel
import ModelCompatibility

private let minimumContextSize = UInt(512)

public func defaultModelParameters() -> LlamaFamilyModelParameters {
//  switch chatSourceType {
//  case .llama:
    return LlamaFamilyModelParameters.from(
      sessionConfig: LlamaSessionConfig.configurableDefaults
        .withHyperparameters { hyperparameters in
          hyperparameters.withContextSize(hyperparameters.contextSize.map { max($0, minimumContextSize) })
        }
        .build()
    )
//  case .alpaca:
//    return LlamaFamilyModelParameters.from(
//      sessionConfig: AlpacaSessionConfig.configurableDefaults
//        .withHyperparameters { hyperparameters in
//          hyperparameters.withContextSize(hyperparameters.contextSize.map { max($0, minimumContextSize) })
//        }
//        .build()
//    )
//  case .gpt4All:
//    return LlamaFamilyModelParameters.from(
//      sessionConfig: GPT4AllSessionConfig.configurableDefaults
//        .withHyperparameters { hyperparameters in
//          hyperparameters.withContextSize(hyperparameters.contextSize.map { max($0, minimumContextSize) })
//        }
//        .build()
//    )
//  }
}

fileprivate extension LlamaFamilyModelParameters {
  static func from(sessionConfig: SessionConfig) -> LlamaFamilyModelParameters {
    return LlamaFamilyModelParameters(
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
