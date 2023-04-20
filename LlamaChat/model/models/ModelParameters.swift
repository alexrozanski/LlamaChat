//
//  ModelParameters.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import Foundation

class ModelParameters: ObservableObject, Codable {
  @Published var seedValue: Int32?

  @Published var contextSize: UInt
  @Published var numberOfTokens: UInt

  @Published var topP: Double
  @Published var topK: UInt
  @Published var temperature: Double
  @Published var batchSize: UInt

  @Published var lastNTokensToPenalize: UInt
  @Published var repeatPenalty: Double

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

  init(
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

  required init(from decoder: Decoder) throws {
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

  func encode(to encoder: Encoder) throws {
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
