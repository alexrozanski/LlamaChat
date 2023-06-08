//
//  LlamaFamilyModelParameters.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import Foundation
import DataModel

public class GPT4AllModelParameters: ObservableObject, ModelParameters {
  @Published public var numberOfTokens: UInt

  @Published public var topP: Double
  @Published public var topK: UInt
  @Published public var temperature: Double
  @Published public var batchSize: UInt

  @Published public var repeatPenalty: Double

  public init(
    numberOfTokens: UInt,
    topP: Double,
    topK: UInt,
    temperature: Double,
    batchSize: UInt,
    repeatPenalty: Double
  ) {
    self.numberOfTokens = numberOfTokens
    self.topP = topP
    self.topK = topK
    self.temperature = temperature
    self.batchSize = batchSize
    self.repeatPenalty = repeatPenalty
  }
}
