//
//  VariantInference.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import DataModel
import CameLLM
import CameLLMLlama
import CameLLMGPTJ

public func inferVariantForModelFile(at modelURL: URL, model: Model) -> ModelVariant? {
  for engine in Set(model.variants.map { $0.engine }) {
    do {
      switch engine {
      case "camellm-llama":
        let modelCard = try ModelUtils.llamaFamily.getModelCard(forFileAt: modelURL)
        let parameters = modelCard?.parameters
        if let variant = model.variants.first(where: { variant in
          return variant.parameters.map { modelParams in parameters.map { modelParams.equal(to: $0) } ?? false } ?? false
        }) {
          return variant
        }
      default:
        break
      }
    } catch {
      continue
    }
  }

  return nil
}

