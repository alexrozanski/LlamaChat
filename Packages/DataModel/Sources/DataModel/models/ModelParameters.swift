//
//  ModelParameters.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import Foundation

public class ModelParameters: ObservableObject, Codable {
  @Published public var seedValue: Int32?

  @Published public var contextSize: UInt
  @Published public var numberOfTokens: UInt

  @Published public var topP: Double
  @Published public var topK: UInt
  @Published public var temperature: Double
  @Published public var batchSize: UInt

  @Published public var lastNTokensToPenalize: UInt
  @Published public var repeatPenalty: Double

  public enum CodingKeys: CodingKey {
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

  public required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    seedValue = try values.decode(Int32?.self, forKey: .seedValue)
    contextSize = try values.decode(UInt.self, forKey: .contextSize)
    numberOfTokens = try values.decode(UInt.self, forKey: .numberOfTokens)
    topP = try values.decode(Double.self, forKey: .topP)
    topK = try values.decode(UInt.self, forKey: .topK)
    temperature = try values.decode(Double.self, forKey: .temperature)
    batchSize = try values.decode(UInt.self, forKey: .batchSize)
    lastNTokensToPenalize = try values.decode(UInt.self, forKey: .lastNTokensToPenalize)
    repeatPenalty = try values.decode(Double.self, forKey: .repeatPenalty)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(seedValue, forKey: .seedValue)
    try container.encode(contextSize, forKey: .contextSize)
    try container.encode(numberOfTokens, forKey: .numberOfTokens)
    try container.encode(topP, forKey: .topP)
    try container.encode(topK, forKey: .topK)
    try container.encode(temperature, forKey: .temperature)
    try container.encode(batchSize, forKey: .batchSize)
    try container.encode(lastNTokensToPenalize, forKey: .lastNTokensToPenalize)
    try container.encode(repeatPenalty, forKey: .repeatPenalty)
  }
}
