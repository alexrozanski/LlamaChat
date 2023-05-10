//
//  LlamaFamilyModelParametersViewModel.swift
//  
//
//  Created by Alex Rozanski on 10/05/2023.
//

import Foundation
import SwiftUI
import Combine
import AppModel
import ChatInfoUI
import DataModel
import ModelCompatibility
import SettingsUI

public class LlamaFamilyModelParametersViewModel: ObservableObject, ModelParametersViewModel {
  var sourceId: String {
    return chatModel.source.id
  }

  @Published private(set) var context: ModelStat<String> = .none
  @Published private(set) var contextTokenCount: ModelStat<Int> = .none

  @Published public var seedValue: Int32?
  @Published public var contextSize: UInt = 0
  @Published public var numberOfTokens: UInt = 0
  @Published public var topP: Double = 0
  @Published public var topK: UInt = 0
  @Published public var temperature: Double = 0
  @Published public var batchSize: UInt = 0
  @Published public var lastNTokensToPenalize: UInt = 0
  @Published public var repeatPenalty: Double = 0

  let chatModel: ChatModel
  @ObservedObject var parameters: LlamaFamilyModelParameters

  public init(chatModel: ChatModel, parameters: LlamaFamilyModelParameters) {
    self.chatModel = chatModel
    self.parameters = parameters

    self.parameters
      .$seedValue
      .assign(to: &$seedValue)
    self.parameters
      .$contextSize
      .assign(to: &$contextSize)
    self.parameters
      .$numberOfTokens
      .assign(to: &$numberOfTokens)
    self.parameters
      .$topP
      .assign(to: &$topP)
    self.parameters
      .$topK
      .assign(to: &$topK)
    self.parameters
      .$temperature
      .assign(to: &$temperature)
    self.parameters
      .$batchSize
      .assign(to: &$batchSize)
    self.parameters
      .$lastNTokensToPenalize
      .assign(to: &$lastNTokensToPenalize)
    self.parameters
      .$repeatPenalty
      .assign(to: &$repeatPenalty)
  }

  func configureParameters() {
    SettingsWindowPresenter.shared.present(deeplinkingTo: .sources(sourceId: chatModel.source.id, sourcesTab: .parameters))
  }

  func loadModelStats() {
    context = .loading
    contextTokenCount = .loading

    Task.init {
      do {
        let context = try await chatModel.loadContext()
        await MainActor.run {
          self.context = context?.contextString.flatMap { .value($0) } ?? .none
          let tokenCount = context?.tokens?.count
          self.contextTokenCount = tokenCount.map { .value($0) } ?? .none
        }
      } catch {
        self.context = .unknown
        self.contextTokenCount = .unknown
      }
    }
  }
}
