//
//  LlamaFamilyModelParameters.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import Foundation
import DataModel

public class LlamaFamilyModelParameters: ObservableObject, ModelParameters {
  public enum Mode: String {
    case regular
    case instructional

    public init?(rawValue: String) {
      switch rawValue {
      case "regular": self = .regular
      case "instructional": self = .instructional
      default: return nil
      }
    }
  }

  @Published public var mode: Mode
  @Published public var seedValue: Int32?

  @Published public var contextSize: UInt
  @Published public var numberOfTokens: UInt

  @Published public var topP: Double
  @Published public var topK: UInt
  @Published public var temperature: Double
  @Published public var batchSize: UInt

  @Published public var lastNTokensToPenalize: UInt
  @Published public var repeatPenalty: Double

  @Published public var initialPrompt: String?
  @Published public var promptPrefix: String?
  @Published public var promptSuffix: String?
  @Published public var antiprompt: String?

  public init(
    mode: Mode,
    seedValue: Int32?,
    contextSize: UInt,
    numberOfTokens: UInt,
    topP: Double,
    topK: UInt,
    temperature: Double,
    batchSize: UInt,
    lastNTokensToPenalize: UInt,
    repeatPenalty: Double,
    initialPrompt: String?,
    promptPrefix: String?,
    promptSuffix: String?,
    antiprompt: String?
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
}
