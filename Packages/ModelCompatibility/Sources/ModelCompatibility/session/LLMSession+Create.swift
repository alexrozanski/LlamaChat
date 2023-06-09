//
//  LLMSession+Create.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import DataModel

public func makeSession(
  for chatSource: ChatSource,
  numThreads: UInt,
  delegate: LLMSessionDelegate
) -> LLMSession? {
  guard let variant = chatSource.modelVariant else { return nil }

  switch variant.engine {
  case "camellm-llama":
    guard let modelParameters = chatSource.modelParameters?.wrapped as? LlamaFamilyModelParameters else { return nil }

    return makeLlamaFamilyLLMSession(
      for: chatSource,
      modelParameters: modelParameters,
      numThreads: numThreads,
      delegate: delegate
    )
  case "camellm-gptj":
    guard let modelParameters = chatSource.modelParameters?.wrapped as? GPT4AllModelParameters else { return nil }

    return makeGPT4AllLLMSession(
      for: chatSource,
      modelParameters: modelParameters,
      numThreads: numThreads,
      delegate: delegate
    )
  default:
    return nil
  }
}
