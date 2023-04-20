//
//  SourceSettingsParametersViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 19/04/2023.
//

import Foundation
import Combine

class SourceSettingsParametersViewModel: ObservableObject {
  enum RestorableKey: String {
    case showDetails
  }

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

  @Published var showDetails: Bool

  private let restorableData: any RestorableData<RestorableKey>
  private var subscriptions = Set<AnyCancellable>()

  let source: ChatSource
  init(source: ChatSource, stateRestoration: StateRestoration) {
    self.source = source
    self.restorableData = stateRestoration.restorableData(for: "SourceSettingsParametersViewModel")

    _showDetails = Published(initialValue: restorableData.getValue(for: .showDetails) ?? false)

    $showDetails.receive(on: DispatchQueue.main).sink { [weak self] in
      self?.restorableData.set(value: $0, for: .showDetails)
    }.store(in: &subscriptions)

    setUpDataBindings()
  }

  func resetDefaults() {
    source.resetDefaultParameters()
  }

  // The values in source.modelParameters remain the source of truth here, but we want to assign their
  // values to our own @Published values. However we also want to assign the values through our
  // @Published values back to source.modelParameters (without creating an infinite loop). We remove
  // the infinite loop risk by using removeDuplicates() from one direction, but this is also made
  // more complicated by the fact that source.modelParameters can also change, so we can't use assign().
  //
  // If there is a better way of doing this, please open a PR!
  private func setUpDataBindings() {
    source.$modelParameters
      .map { $0.$seedValue }
      .switchToLatest()
      .map { $0 == nil }
      .assign(to: &$isSeedRandom)
    $isSeedRandom
      .removeDuplicates()
      .sink { [weak source] newIsSeedRandom in
        if newIsSeedRandom {
          source?.modelParameters.seedValue = nil
        }
      }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$seedValue }
      .switchToLatest()
      .assign(to: &$seedValue)
    $seedValue
      .removeDuplicates()
      .sink { [weak source] in source?.modelParameters.seedValue = $0 }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$contextSize }
      .switchToLatest()
      .map { Int($0) }
      .assign(to: &$contextSize)
    $contextSize.map { UInt($0) }
      .removeDuplicates()
      .sink { [weak source] in source?.modelParameters.contextSize = $0 }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$numberOfTokens }
      .switchToLatest()
      .removeDuplicates()
      .map { Int($0) }
      .assign(to: &$numberOfTokens)
    $numberOfTokens
      .map { UInt($0) }
      .sink { [weak source] in source?.modelParameters.numberOfTokens = $0 }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$topP }
      .switchToLatest()
      .removeDuplicates()
      .assign(to: &$topP)
    $topP
      .sink { [weak source] in source?.modelParameters.topP = $0 }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$topK }
      .switchToLatest()
      .removeDuplicates()
      .map { Int($0) }
      .assign(to: &$topK)
    $topK
      .map { UInt($0) }
      .sink { [weak source] in source?.modelParameters.topK = $0 }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$temperature }
      .switchToLatest()
      .removeDuplicates()
      .assign(to: &$temperature)
    $temperature
      .sink { [weak source] in source?.modelParameters.temperature = $0 }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$batchSize }
      .switchToLatest()
      .removeDuplicates()
      .map { Int($0) }
      .assign(to: &$batchSize)
    $batchSize
      .map { UInt($0) }
      .sink { [weak source] in source?.modelParameters.batchSize = $0 }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$lastNTokensToPenalize }
      .switchToLatest()
      .removeDuplicates()
      .map { Int($0) }
      .assign(to: &$lastNTokensToPenalize)
    $lastNTokensToPenalize
      .map { UInt($0) }
      .sink { [weak source] in source?.modelParameters.lastNTokensToPenalize = $0 }
      .store(in: &subscriptions)

    source.$modelParameters
      .map { $0.$repeatPenalty }
      .switchToLatest()
      .removeDuplicates()
      .assign(to: &$repeatPenalty)
    $repeatPenalty
      .sink { [weak source] in source?.modelParameters.repeatPenalty = $0 }
      .store(in: &subscriptions)
  }
}
