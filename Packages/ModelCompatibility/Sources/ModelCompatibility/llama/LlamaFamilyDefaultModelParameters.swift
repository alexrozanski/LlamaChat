//
//  LlamaFamilyDefaultModelParameters.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import AnyCodable
import DataModel

public class LlamaFamilyDefaultModelParameters {
  public var mode: LlamaFamilyModelParameters.Mode?
  public var seedValue: Int32??

  public var contextSize: UInt?
  public var numberOfTokens: UInt?

  public var topP: Double?
  public var topK: UInt?
  public var temperature: Double?
  public var batchSize: UInt?

  public var lastNTokensToPenalize: UInt?
  public var repeatPenalty: Double?

  public var initialPrompt: String??
  public var promptPrefix: String??
  public var promptSuffix: String??
  public var antiprompt: String??

  public init(
    mode: LlamaFamilyModelParameters.Mode?,
    seedValue: Int32??,
    contextSize: UInt?,
    numberOfTokens: UInt?,
    topP: Double?,
    topK: UInt?,
    temperature: Double?,
    batchSize: UInt?,
    lastNTokensToPenalize: UInt?,
    repeatPenalty: Double?,
    initialPrompt: String??,
    promptPrefix: String??,
    promptSuffix: String??,
    antiprompt: String??
  ) {
    self.mode = mode
    self.seedValue = seedValue
    self.contextSize = contextSize
    self.numberOfTokens = numberOfTokens
    self.topP = topP
    self.topK = topK
    self.temperature = temperature
    self.batchSize = batchSize
    self.lastNTokensToPenalize = lastNTokensToPenalize
    self.repeatPenalty = repeatPenalty
    self.initialPrompt = initialPrompt
    self.promptPrefix = promptPrefix
    self.promptSuffix = promptSuffix
    self.antiprompt = antiprompt
  }

  public static func from(dictionary defaultParameters: [String: AnyCodable]) -> LlamaFamilyDefaultModelParameters {
    return LlamaFamilyDefaultModelParameters(
      mode: (defaultParameters["mode"]?.value as? String).map({ LlamaFamilyModelParameters.Mode(rawValue: $0) }) ?? nil,
      seedValue: (defaultParameters["seed"]?.value as? Int).map { Int32($0) },
      contextSize: (defaultParameters["contextSize"]?.value as? Int).map { UInt($0) },
      numberOfTokens: (defaultParameters["numTokens"]?.value as? Int).map { UInt($0) },
      topP: defaultParameters["topP"]?.value as? Double,
      topK: (defaultParameters["topK"]?.value as? Int).map { UInt($0) },
      temperature: defaultParameters["temperature"]?.value as? Double,
      batchSize: (defaultParameters["batchSize"]?.value as? Int).map { UInt($0) },
      lastNTokensToPenalize: (defaultParameters["lastNTokensToPenalize"]?.value as? Int).map { UInt($0) },
      repeatPenalty: defaultParameters["repeatPenalty"]?.value as? Double,
      initialPrompt: defaultParameters["initialPrompt"]?.value as? String,
      promptPrefix: defaultParameters["promptPrefix"]?.value as? String,
      promptSuffix: defaultParameters["promptSuffix"]?.value as? String,
      antiprompt: defaultParameters["antiprompt"]?.value as? String
    )
  }
}
