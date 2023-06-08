//
//  GPT4AllDefaultModelParameters.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import AnyCodable
import DataModel

public class GPT4AllDefaultModelParameters {
  public var numberOfTokens: UInt?

  public var topP: Double?
  public var topK: UInt?
  public var temperature: Double?
  public var batchSize: UInt?

  public var repeatPenalty: Double?

  public init(
    numberOfTokens: UInt?,
    topP: Double?,
    topK: UInt?,
    temperature: Double?,
    batchSize: UInt?,
    repeatPenalty: Double?
  ) {
    self.numberOfTokens = numberOfTokens
    self.topP = topP
    self.topK = topK
    self.temperature = temperature
    self.batchSize = batchSize
    self.repeatPenalty = repeatPenalty
  }

  public static func from(dictionary defaultParameters: [String: AnyCodable]) -> GPT4AllDefaultModelParameters {
    return GPT4AllDefaultModelParameters(
      numberOfTokens: (defaultParameters["numTokens"]?.value as? Int).map { UInt($0) },
      topP: defaultParameters["topP"]?.value as? Double,
      topK: (defaultParameters["topK"]?.value as? Int).map { UInt($0) },
      temperature: defaultParameters["temperature"]?.value as? Double,
      batchSize: (defaultParameters["batchSize"]?.value as? Int).map { UInt($0) },
      repeatPenalty: defaultParameters["repeatPenalty"]?.value as? Double
    )
  }
}
