//
//  GPT4AllModelParameters+Defaults.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import Foundation
import CameLLMGPTJ
import DataModel

public extension GPT4AllModelParameters {
  static func defaultParameters(for model: Model) -> GPT4AllModelParameters {
    guard let defaultParameters = model.defaultParameters else {
      return GPT4AllModelParameters.from(sessionConfig: SessionConfig.defaults)
    }

    let modelDefaults = GPT4AllDefaultModelParameters.from(dictionary: defaultParameters)
    let newParameters = GPT4AllModelParameters.from(
      sessionConfig: SessionConfig.configurableDefaults()
        .withNumTokens(modelDefaults.numberOfTokens)
        .withHyperparameters { hyperparameters in
          hyperparameters
            .withBatchSize(modelDefaults.batchSize)
            .withTopK(modelDefaults.topK)
            .withTopP(modelDefaults.topP)
            .withTemperature(modelDefaults.temperature)
            .withRepeatPenalty(modelDefaults.repeatPenalty)
        }
        .build()
    )
    return newParameters
  }
}

fileprivate extension GPT4AllModelParameters {
  static func from(sessionConfig: SessionConfig) -> GPT4AllModelParameters {
    return GPT4AllModelParameters(
      numberOfTokens: sessionConfig.numTokens,
      topP: sessionConfig.hyperparameters.topP,
      topK: sessionConfig.hyperparameters.topK,
      temperature: sessionConfig.hyperparameters.temperature,
      batchSize: sessionConfig.hyperparameters.batchSize,
      repeatPenalty: sessionConfig.hyperparameters.repeatPenalty
    )
  }
}
