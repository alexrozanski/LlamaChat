//
//  GeneralSettingsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 15/04/2023.
//

import Foundation
import AppModel

class GeneralSettingsViewModel: ObservableObject {
  @Published var numThreads: Int {
    didSet {
      AppSettingsModel.shared.numThreads = numThreads
    }
  }

  var threadCountRange: ClosedRange<Int> {
    return ProcessInfo.processInfo.threadCountRange
  }

  init() {
    numThreads = AppSettingsModel.shared.numThreads

    AppSettingsModel.shared.$numThreads.receive(on: DispatchQueue.main).assign(to: &$numThreads)
  }
}
