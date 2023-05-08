//
//  CheckForUpdatesViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 13/04/2023.
//

import Foundation
import Sparkle

final class CheckForUpdatesViewModel: ObservableObject {
  @Published var canCheckForUpdates = false

  let updaterController: SPUStandardUpdaterController

  init() {
    updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    updaterController.updater.publisher(for: \.canCheckForUpdates).assign(to: &$canCheckForUpdates)
  }

  func checkForUpdates() {
    updaterController.updater.checkForUpdates()
  }
}

