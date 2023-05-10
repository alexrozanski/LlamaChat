//
//  ParametersCompatibility.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import Foundation
import CameLLM
import DataModel

public extension ModelParameterSize {
  func equal(to parameterSize: ParameterSize) -> Bool {
    return toCameLLMParameters() == parameterSize
  }

  func toCameLLMParameters() -> ParameterSize {
    switch self {
    case .millions(let m):
      return .millions(m)
    case .billions(let b):
      return .billions(b)
    }
  }
}
