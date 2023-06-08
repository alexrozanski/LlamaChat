//
//  DefaultModelParametersProvider.swift
//  
//
//  Created by Alex Rozanski on 09/06/2023.
//

import Foundation
import DataModel

public class DefaultModelParametersProvider {
  private init() {}

  public static func defaultParameters(for model: Model, variant: ModelVariant?) -> AnyModelParameters {
    guard let engine = engine(for: model, variant: variant) else {
      return AnyModelParameters(EmptyModelParameters())
    }
    return defaultParameters(for: model, engine: engine)
  }

  // MARK: - Private

  private static func defaultParameters(for model: Model, engine: String) -> AnyModelParameters {
    switch engine {
    case "camellm-llama":
      return AnyModelParameters(LlamaFamilyModelParameters.defaultParameters(for: model))
    case "camellm-gptj":
      return AnyModelParameters(GPT4AllModelParameters.defaultParameters(for: model))
    default:
      return AnyModelParameters(EmptyModelParameters())
    }
  }
}
