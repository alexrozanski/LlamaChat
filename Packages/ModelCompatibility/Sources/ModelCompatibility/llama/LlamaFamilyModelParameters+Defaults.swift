//
//  LlamaFamilyModelParameters+Defaults.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import Foundation
import CameLLMLlama
import DataModel

private let minimumContextSize = UInt(512)

public extension LlamaFamilyModelParameters {
  static func defaultParameters(for model: Model) -> LlamaFamilyModelParameters {
    guard let defaultParameters = model.defaultParameters else {
      return LlamaFamilyModelParameters.from(sessionConfig: LlamaSessionConfig.defaults)
    }

    let contextSize = (defaultParameters["contextSize"]?.value as? Int).map { UInt($0) }
    let newParameters = LlamaFamilyModelParameters.from(
      sessionConfig: LlamaSessionConfig.configurableDefaults
        .withSeed(defaultParameters["seed"]?.value as? Int32)
        .withNumTokens((defaultParameters["numTokens"]?.value as? Int).map { UInt($0) })
        .withHyperparameters { hyperparameters in
          hyperparameters
            .withContextSize(max(contextSize ?? 0, minimumContextSize))
            .withBatchSize((defaultParameters["batchSize"]?.value as? Int).map { UInt($0) })
            .withLastNTokensToPenalize((defaultParameters["lastNTokensToPenalize"]?.value as? Int).map { UInt($0) })
            .withTopK((defaultParameters["topK"]?.value as? Int).map { UInt($0) })
            .withTopP(defaultParameters["topP"]?.value as? Double)
            .withTemperature(defaultParameters["temperature"]?.value as? Double)
          .withRepeatPenalty(defaultParameters["repeatPenalty"]?.value as? Double)
        }
        .build()
    )
    return newParameters
  }
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
