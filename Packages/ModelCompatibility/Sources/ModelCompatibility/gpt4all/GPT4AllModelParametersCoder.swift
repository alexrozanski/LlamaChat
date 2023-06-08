//
//  GPT4AllModelParametersCoder.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import DataModel

public class GPT4AllModelParametersCoder: ModelParametersCoder {
  enum CodingKeys: CodingKey {
    case numberOfTokens
    case topP
    case topK
    case temperature
    case batchSize
    case repeatPenalty
  }

  public init() {}

  public func decodeParameters<Key>(
    in container: KeyedDecodingContainer<Key>,
    forKey key: Key,
    modelId: String,
    variantId: String?
  ) throws -> AnyModelParameters where Key: CodingKey {
    let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: key)
    let numberOfTokens = try values.decode(UInt.self, forKey: .numberOfTokens)
    let topP = try values.decode(Double.self, forKey: .topP)
    let topK = try values.decode(UInt.self, forKey: .topK)
    let temperature = try values.decode(Double.self, forKey: .temperature)
    let batchSize = try values.decode(UInt.self, forKey: .batchSize)
    let repeatPenalty = try values.decode(Double.self, forKey: .repeatPenalty)

    return AnyModelParameters(
      GPT4AllModelParameters(
        numberOfTokens: numberOfTokens,
        topP: topP,
        topK: topK,
        temperature: temperature,
        batchSize: batchSize,
        repeatPenalty: repeatPenalty
      )
    )
  }

  public func encode<Key>(parameters: AnyModelParameters, to container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws where Key: CodingKey {
    guard let parameters = parameters.wrapped as? GPT4AllModelParameters else {
      throw ModelParametersCoderError.unsupportedParameters
    }

    var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: key)
    try nestedContainer.encode(parameters.numberOfTokens, forKey: .numberOfTokens)
    try nestedContainer.encode(parameters.topP, forKey: .topP)
    try nestedContainer.encode(parameters.topK, forKey: .topK)
    try nestedContainer.encode(parameters.temperature, forKey: .temperature)
    try nestedContainer.encode(parameters.batchSize, forKey: .batchSize)
    try nestedContainer.encode(parameters.repeatPenalty, forKey: .repeatPenalty)
  }
}

private func defaultParameters(for modelId: String) -> GPT4AllDefaultModelParameters? {
  guard let parameters = BuiltinMetadataModels.all.first(where: { $0.id == modelId })?.defaultParameters else {
    return nil
  }

  return GPT4AllDefaultModelParameters.from(dictionary: parameters)
}

private func decodeMode(from container: KeyedDecodingContainer<LlamaFamilyModelParametersCoder.CodingKeys>) throws -> LlamaFamilyModelParameters.Mode {
  let mode = try container.decode(String.self, forKey: .mode)
  switch mode {
  case "regular":
    return .regular
  case "instructional":
    return .instructional
  default:
    throw DecodingError.typeMismatch(
      LlamaFamilyModelParameters.Mode.self,
      DecodingError.Context(codingPath: [LlamaFamilyModelParametersCoder.CodingKeys.mode], debugDescription: "unsupported mode '\(mode)'")
    )
  }
}
