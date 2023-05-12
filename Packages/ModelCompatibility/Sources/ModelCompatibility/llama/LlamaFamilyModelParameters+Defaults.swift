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
      return LlamaFamilyModelParameters.from(sessionConfig: SessionConfig.defaults)
    }

    let modelDefaults = LlamaFamilyDefaultModelParameters.from(dictionary: defaultParameters)
    let newParameters = LlamaFamilyModelParameters.from(
      sessionConfig: SessionConfig.configurableDefaults()
        .withMode(modelDefaults.mode?.toSessionConfig())
        .withSeed(modelDefaults.seedValue)
        .withNumTokens(modelDefaults.numberOfTokens)
        .withHyperparameters { hyperparameters in
          hyperparameters
            .withContextSize(max(modelDefaults.contextSize ?? 0, minimumContextSize))
            .withBatchSize(modelDefaults.batchSize)
            .withLastNTokensToPenalize(modelDefaults.lastNTokensToPenalize)
            .withTopK(modelDefaults.topK)
            .withTopP(modelDefaults.topP)
            .withTemperature(modelDefaults.temperature)
            .withRepeatPenalty(modelDefaults.repeatPenalty)
        }
        .withInitialPrompt(modelDefaults.initialPrompt)
        .withPromptPrefix(modelDefaults.promptPrefix)
        .withPromptSuffix(modelDefaults.promptSuffix)
        .withAntiprompt(modelDefaults.antiprompt)
        .build()
    )
    return newParameters
  }
}

fileprivate extension LlamaFamilyModelParameters {
  static func from(sessionConfig: SessionConfig) -> LlamaFamilyModelParameters {
    return LlamaFamilyModelParameters(
      mode: LlamaFamilyModelParameters.Mode.fromSessionConfig(sessionConfig.mode),
      seedValue: sessionConfig.seed,
      contextSize: sessionConfig.hyperparameters.contextSize,
      numberOfTokens: sessionConfig.numTokens,
      topP: sessionConfig.hyperparameters.topP,
      topK: sessionConfig.hyperparameters.topK,
      temperature: sessionConfig.hyperparameters.temperature,
      batchSize: sessionConfig.hyperparameters.batchSize,
      lastNTokensToPenalize: sessionConfig.hyperparameters.lastNTokensToPenalize,
      repeatPenalty: sessionConfig.hyperparameters.repeatPenalty,
      initialPrompt: sessionConfig.initialPrompt,
      promptPrefix: sessionConfig.promptPrefix,
      promptSuffix: sessionConfig.promptSuffix,
      antiprompt: sessionConfig.antiprompt
    )
  }
}

fileprivate extension SessionConfig.Mode {
  static func fromString(_ string: String) -> SessionConfig.Mode? {
    switch string {
    case "regular": return .regular
    case "instructional": return .instructional
    default: return nil
    }
  }
}

fileprivate extension LlamaFamilyModelParameters.Mode {
  func toSessionConfig() -> SessionConfig.Mode {
    switch self {
    case .regular: return .regular
    case .instructional: return .instructional
    }
  }

  static func fromSessionConfig(_ mode: SessionConfig.Mode) -> LlamaFamilyModelParameters.Mode {
    switch mode {
    case .regular: return .regular
    case .instructional: return .instructional
    }
  }
}
