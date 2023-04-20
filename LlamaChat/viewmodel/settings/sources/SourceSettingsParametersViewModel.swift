//
//  SourceSettingsParametersViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 19/04/2023.
//

import Foundation

class SourceSettingsParametersViewModel: ObservableObject {
  @Published var isSeedRandom = false
  @Published var seedValue: Int32? = nil

  @Published var contextSize: Int = 128
  @Published var numberOfTokens: Int = 128

  @Published var topP: Double = 0
  @Published var topK: Int = 0
  @Published var temperature: Double = 0
  @Published var batchSize: Int = 1

  @Published var lastNTokensToPenalize: Int = 1
  @Published var repeatPenalty: Double = 1

  let modelParameters: ModelParameters
  init(modelParameters: ModelParameters) {
    self.modelParameters = modelParameters

    modelParameters.$seedValue.map { $0 == nil }.assign(to: &$isSeedRandom)
    modelParameters.$seedValue.assign(to: &$seedValue)

    modelParameters.$contextSize.map { Int($0) }.assign(to: &$contextSize)
    modelParameters.$numberOfTokens.map { Int($0) }.assign(to: &$numberOfTokens)

    modelParameters.$topP.assign(to: &$topP)
    modelParameters.$topK.map { Int($0) }.assign(to: &$topK)
    modelParameters.$temperature.assign(to: &$temperature)
    modelParameters.$batchSize.map { Int($0) }.assign(to: &$batchSize)

    modelParameters.$lastNTokensToPenalize.map { Int($0) }.assign(to: &$lastNTokensToPenalize)
    modelParameters.$repeatPenalty.assign(to: &$repeatPenalty)
  }
}
