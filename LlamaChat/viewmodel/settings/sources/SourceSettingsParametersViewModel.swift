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
}
