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
  @Published private(set) var context: ModelStat<String> = .none
  @Published private(set) var contextTokenCount: ModelStat<Int> = .none

  @Published public var isSeedRandom = false
  @Published public var seedValue: Int32? = nil
  @Published public var contextSize: UInt = 0
  @Published public var numberOfTokens: UInt = 0
  @Published public var topP: Double = 0
  @Published public var topK: UInt = 0
  @Published public var temperature: Double = 0
  @Published public var batchSize: UInt = 0
  @Published public var lastNTokensToPenalize: UInt = 0
  @Published public var repeatPenalty: Double = 0

  weak var chatModel: ChatModel?
  @ObservedObject var parameters: LlamaFamilyModelParameters

  public let id = UUID().uuidString
  let sourceId: String

  public init(chatModel: ChatModel, parameters: LlamaFamilyModelParameters) {
    self.sourceId = chatModel.source.id
    self.chatModel = chatModel
    self.parameters = parameters

    setUpDataBindings()
  }

  func configureParameters() {
    guard let chatModel else { return }
    SettingsWindowPresenter.shared.present(deeplinkingTo: .sources(sourceId: chatModel.source.id, sourcesTab: .parameters))
  }

  func loadModelStats() {
    guard let chatModel else { return }

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

  // The values in `parameters` remain the source of truth here, but we want to assign their
  // values to our own @Published values. However we also want to assign the values through our
  // @Published values back to `parameters` (without creating an infinite loop). We remove
  // the infinite loop risk by using removeDuplicates() from one direction.
  //
  // Finally we call dropFirst() on the chain going back the other way so that the initial connection from
  // our @Published values back to the values on the ModelParameters doesn't trigger a change event.
  //
  // If there is a better way of doing this, please open a PR!
  private func setUpDataBindings() {
    parameters
      .$seedValue
      .assign(to: &$seedValue)
    parameters
      .$seedValue
      .map { $0 == nil }
      .assign(to: &$isSeedRandom)
    $seedValue
      .removeDuplicates()
      .combineLatest($isSeedRandom.removeDuplicates())
      .dropFirst()
      .map { seedValue, isSeedRandom in
        return isSeedRandom ? nil : seedValue
      }
      .assign(to: &parameters.$seedValue)

    parameters
      .$contextSize
      .assign(to: &$contextSize)
    $contextSize
      .map { UInt($0) }
      .removeDuplicates()
      .dropFirst()
      .assign(to: &parameters.$contextSize)

    parameters
      .$numberOfTokens
      .assign(to: &$numberOfTokens)
    $numberOfTokens
      .map { UInt($0) }
      .removeDuplicates()
      .dropFirst()
      .assign(to: &parameters.$numberOfTokens)

    parameters
      .$topP
      .assign(to: &$topP)
    $topP
      .removeDuplicates()
      .dropFirst()
      .assign(to: &parameters.$topP)

    parameters
      .$topK
      .assign(to: &$topK)
    $topK
      .map { UInt($0) }
      .removeDuplicates()
      .dropFirst()
      .assign(to: &parameters.$topK)

    parameters
      .$temperature
      .assign(to: &$temperature)
    $temperature
      .removeDuplicates()
      .dropFirst()
      .assign(to: &parameters.$temperature)

    parameters
      .$batchSize
      .assign(to: &$batchSize)
    $batchSize
      .map { UInt($0) }
      .removeDuplicates()
      .dropFirst()
      .assign(to: &parameters.$batchSize)

    parameters
      .$lastNTokensToPenalize
      .assign(to: &$lastNTokensToPenalize)
    $lastNTokensToPenalize
      .map { UInt($0) }
      .removeDuplicates()
      .dropFirst()
      .assign(to: &parameters.$lastNTokensToPenalize)

    parameters
      .$repeatPenalty
      .assign(to: &$repeatPenalty)
    $repeatPenalty
      .removeDuplicates()
      .dropFirst()
      .assign(to: &parameters.$repeatPenalty)
  }
}
