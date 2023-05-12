//
//  LLMSessionErrorUtils.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import CameLLM

public func predictionErrorMessage(from error: Error) -> String {
  let nsError = error as NSError
  if nsError.domain == CameLLMError.Domain {
    if let code = CameLLMError.Code(rawValue: nsError.code) {
      switch code {
      case .failedToLoadModel:
        return "Failed to load model"
      case .failedToPredict:
        return "Failed to generate response"
      default:
        break
      }
    }
  }
  return "Failed to generate response"
}
