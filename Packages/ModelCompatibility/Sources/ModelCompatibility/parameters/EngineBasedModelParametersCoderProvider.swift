//
//  EngineBasedModelParametersCoderProvider.swift
//  
//
//  Created by Alex Rozanski on 09/06/2023.
//

import Foundation
import DataModel

public class EngineBasedModelParametersCoderProvider: ModelParametersCoderProvider {
  public init() {}

  public func modelParametersCoder(for model: Model, variant: ModelVariant?) -> ModelParametersCoder? {
    guard let engine = engine(for: model, variant: variant) else {
      return nil
    }

    switch engine {
    case "camellm-llama":
      return LlamaFamilyModelParametersCoder()
    case "camellm-gptj":
      return GPT4AllModelParametersCoder()
    default:
      return nil
    }
  }
}
