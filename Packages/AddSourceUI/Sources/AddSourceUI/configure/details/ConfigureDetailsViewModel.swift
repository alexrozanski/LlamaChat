//
//  ConfigureDetailsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import AppModel
import DataModel

class ConfigureDetailsViewModel: ObservableObject {
  @Published var name: String
  @Published var avatarImageName: String?

  let configuredSource: ConfiguredSource
  let primaryActionsViewModel = PrimaryActionsViewModel()

  init(configuredSource: ConfiguredSource) {
    self.name = configuredSource.model.name
    self.configuredSource = configuredSource

    $name
      .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .map { isValid in
        return PrimaryActionsButton(title: "Add", disabled: !isValid, action: {})
      }
      .assign(to: &primaryActionsViewModel.$continueButton)
  }

  func generateName() {
    if let generatedName = SourceNameGenerator.default.generateName(for: configuredSource.model) {
      name = generatedName
    }
  }
}
