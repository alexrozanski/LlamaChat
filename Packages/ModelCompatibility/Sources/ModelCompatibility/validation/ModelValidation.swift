//
//  ModelValidation.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import DataModel
import CameLLM
import CameLLMLlama
import CameLLMGPTJ

public func validateModelFile(at url: URL, model: Model) -> Bool {
  let engines = Array(Set(model.variants.map { $0.engine }))
  return engines.first { engine in
    do {
      switch engine {
      case "camellm-llama":
        try ModelUtils.llamaFamily.validateModel(at: url)
        return true
      case "camellm-gptj":
        try ModelUtils.gptJ.validateModel(at: url)
        return true
      default:
        return false
      }
    } catch {
      return false
    }
  } != nil
}
