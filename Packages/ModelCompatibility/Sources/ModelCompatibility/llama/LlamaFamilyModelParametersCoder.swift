//
//  LlamaFamilyModelParametersCoder.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import DataModel

public class LlamaFamilyModelParametersCoder: ModelParametersCoder {
  enum CodingKeys: CodingKey {
    case mode
    case seedValue
    case contextSize
    case numberOfTokens
    case topP
    case topK
    case temperature
    case batchSize
    case lastNTokensToPenalize
    case repeatPenalty
    case initialPrompt
    case promptPrefix
    case promptSuffix
    case antiprompt
  }

  public init() {}

  public func decodeParameters<Key>(
    in container: KeyedDecodingContainer<Key>,
    forKey key: Key,
    modelId: String,
    variantId: String?
  ) throws -> AnyModelParameters where Key: CodingKey {
    let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: key)

    let modelDefaults = defaultParameters(for: modelId)

    let mode = try withModelDefault(try decodeMode(from: values), defaults: modelDefaults, keyPath: \.mode)
    let seedValue = try values.decodeIfPresent(Int32.self, forKey: .seedValue)
    let contextSize = try values.decode(UInt.self, forKey: .contextSize)
    let numberOfTokens = try values.decode(UInt.self, forKey: .numberOfTokens)
    let topP = try values.decode(Double.self, forKey: .topP)
    let topK = try values.decode(UInt.self, forKey: .topK)
    let temperature = try values.decode(Double.self, forKey: .temperature)
    let batchSize = try values.decode(UInt.self, forKey: .batchSize)
    let lastNTokensToPenalize = try values.decode(UInt.self, forKey: .lastNTokensToPenalize)
    let repeatPenalty = try values.decode(Double.self, forKey: .repeatPenalty)
    let initialPrompt = withModelDefaultIfPresent(try values.decode(String.self, forKey: .initialPrompt), defaults: modelDefaults, keyPath: \.initialPrompt) ?? nil
    let promptPrefix = withModelDefaultIfPresent(try values.decode(String.self, forKey: .promptPrefix), defaults: modelDefaults, keyPath: \.promptPrefix) ?? nil
    let promptSuffix = withModelDefaultIfPresent(try values.decode(String.self, forKey: .promptSuffix), defaults: modelDefaults, keyPath: \.promptSuffix) ?? nil
    let antiprompt = withModelDefaultIfPresent(try values.decode(String.self, forKey: .antiprompt), defaults: modelDefaults, keyPath: \.antiprompt) ?? nil

    return AnyModelParameters(
      LlamaFamilyModelParameters(
        mode: mode,
        seedValue: seedValue,
        contextSize: contextSize,
        numberOfTokens: numberOfTokens,
        topP: topP,
        topK: topK,
        temperature: temperature,
        batchSize: batchSize,
        lastNTokensToPenalize: lastNTokensToPenalize,
        repeatPenalty: repeatPenalty,
        initialPrompt: initialPrompt,
        promptPrefix: promptPrefix,
        promptSuffix: promptSuffix,
        antiprompt: antiprompt
      )
    )
  }

  public func encode<Key>(parameters: AnyModelParameters, to container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws where Key: CodingKey {
    guard let parameters = parameters.wrapped as? LlamaFamilyModelParameters else {
      throw ModelParametersCoderError.unsupportedParameters
    }

    var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: key)
    try nestedContainer.encodeIfPresent(parameters.mode.rawValue, forKey: .mode)
    try nestedContainer.encode(parameters.seedValue, forKey: .seedValue)
    try nestedContainer.encode(parameters.contextSize, forKey: .contextSize)
    try nestedContainer.encode(parameters.numberOfTokens, forKey: .numberOfTokens)
    try nestedContainer.encode(parameters.topP, forKey: .topP)
    try nestedContainer.encode(parameters.topK, forKey: .topK)
    try nestedContainer.encode(parameters.temperature, forKey: .temperature)
    try nestedContainer.encode(parameters.batchSize, forKey: .batchSize)
    try nestedContainer.encode(parameters.lastNTokensToPenalize, forKey: .lastNTokensToPenalize)
    try nestedContainer.encode(parameters.repeatPenalty, forKey: .repeatPenalty)
    try nestedContainer.encodeIfPresent(parameters.initialPrompt, forKey: .initialPrompt)
    try nestedContainer.encodeIfPresent(parameters.promptPrefix, forKey: .promptPrefix)
    try nestedContainer.encodeIfPresent(parameters.promptSuffix, forKey: .promptSuffix)
    try nestedContainer.encodeIfPresent(parameters.antiprompt, forKey: .antiprompt)
  }
}

private func withModelDefault<T>(
  _ get: @autoclosure () throws -> T,
  defaults: LlamaFamilyDefaultModelParameters?,
  keyPath: KeyPath<LlamaFamilyDefaultModelParameters, Optional<T>>
) throws -> T {
  do {
    return try get()
  } catch {
    if let defaults, let value = defaults[keyPath: keyPath] {
      return value
    }
    throw ModelParametersCoderError.missingDefaultParameter
  }
}

private func withModelDefaultIfPresent<T>(
  _ get: @autoclosure () throws -> T,
  defaults: LlamaFamilyDefaultModelParameters?,
  keyPath: KeyPath<LlamaFamilyDefaultModelParameters, Optional<T>>
) -> T? {
  do {
    return try get()
  } catch {
    if let defaults, let value = defaults[keyPath: keyPath] {
      return value
    }
    return nil
  }
}

private func defaultParameters(for modelId: String) -> LlamaFamilyDefaultModelParameters? {
  guard let parameters = BuiltinMetadataModels.all.first(where: { $0.id == modelId })?.defaultParameters else {
    return nil
  }

  return LlamaFamilyDefaultModelParameters.from(dictionary: parameters)
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
