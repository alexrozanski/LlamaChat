//
//  LlamaFamilyModelParameters.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import Foundation
import DataModel

enum Error: Swift.Error {
  case test
}

public class LlamaFamilyModelParametersCoder: ModelParametersCoder {
  enum CodingKeys: CodingKey {
    case seedValue
    case contextSize
    case numberOfTokens
    case topP
    case topK
    case temperature
    case batchSize
    case lastNTokensToPenalize
    case repeatPenalty
  }

  public init() {}

  public func decodeParameters<Key>(in container: KeyedDecodingContainer<Key>, forKey key: Key) throws -> ModelParameters where Key: CodingKey {
    let values = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: key)

    let seedValue = try values.decode(Int32?.self, forKey: .seedValue)
    let contextSize = try values.decode(UInt.self, forKey: .contextSize)
    let numberOfTokens = try values.decode(UInt.self, forKey: .numberOfTokens)
    let topP = try values.decode(Double.self, forKey: .topP)
    let topK = try values.decode(UInt.self, forKey: .topK)
    let temperature = try values.decode(Double.self, forKey: .temperature)
    let batchSize = try values.decode(UInt.self, forKey: .batchSize)
    let lastNTokensToPenalize = try values.decode(UInt.self, forKey: .lastNTokensToPenalize)
    let repeatPenalty = try values.decode(Double.self, forKey: .repeatPenalty)

    return LlamaFamilyModelParameters(
      seedValue: seedValue,
      contextSize: contextSize,
      numberOfTokens: numberOfTokens,
      topP: topP,
      topK: topK,
      temperature: temperature,
      batchSize: batchSize,
      lastNTokensToPenalize: lastNTokensToPenalize,
      repeatPenalty: repeatPenalty
    )
  }

  public func encode<Key>(parameters: ModelParameters, to container: inout KeyedEncodingContainer<Key>, forKey key: Key) throws where Key: CodingKey {
    guard let parameters = parameters as? LlamaFamilyModelParameters else {
      throw ModelParametersCoderError.unsupportedParameters
    }

    var nestedContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: key)
    try nestedContainer.encode(parameters.seedValue, forKey: .seedValue)
    try nestedContainer.encode(parameters.contextSize, forKey: .contextSize)
    try nestedContainer.encode(parameters.numberOfTokens, forKey: .numberOfTokens)
    try nestedContainer.encode(parameters.topP, forKey: .topP)
    try nestedContainer.encode(parameters.topK, forKey: .topK)
    try nestedContainer.encode(parameters.temperature, forKey: .temperature)
    try nestedContainer.encode(parameters.batchSize, forKey: .batchSize)
    try nestedContainer.encode(parameters.lastNTokensToPenalize, forKey: .lastNTokensToPenalize)
    try nestedContainer.encode(parameters.repeatPenalty, forKey: .repeatPenalty)
  }
}

public class LlamaFamilyModelParameters: ObservableObject, ModelParameters {
  @Published public var seedValue: Int32?

  @Published public var contextSize: UInt
  @Published public var numberOfTokens: UInt

  @Published public var topP: Double
  @Published public var topK: UInt
  @Published public var temperature: Double
  @Published public var batchSize: UInt

  @Published public var lastNTokensToPenalize: UInt
  @Published public var repeatPenalty: Double

  public init(
    seedValue: Int32?,
    contextSize: UInt,
    numberOfTokens: UInt,
    topP: Double,
    topK: UInt,
    temperature: Double,
    batchSize: UInt,
    lastNTokensToPenalize: UInt,
    repeatPenalty: Double
  ) {
    self.seedValue = seedValue
    self.contextSize = contextSize
    self.numberOfTokens = numberOfTokens
    self.topP = topP
    self.topK = topK
    self.temperature = temperature
    self.batchSize = batchSize
    self.lastNTokensToPenalize = lastNTokensToPenalize
    self.repeatPenalty = repeatPenalty
  }
}
