//
//  GeneralSettingsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 15/04/2023.
//

import Foundation
import DataModel

class GeneralSettingsViewModel: ObservableObject {
  @Published var numThreads: Int {
    didSet {
      AppSettings.shared.numThreads = numThreads
    }
  }

  var threadCountRange: ClosedRange<Int> {
    return ProcessInfo.processInfo.threadCountRange
  }

  init() {
    numThreads = AppSettings.shared.numThreads

    AppSettings.shared.$numThreads.receive(on: DispatchQueue.main).assign(to: &$numThreads)
  }
}
