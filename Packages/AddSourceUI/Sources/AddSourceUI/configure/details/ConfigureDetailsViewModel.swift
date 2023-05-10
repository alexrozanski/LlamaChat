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
  typealias NextHandler = (Details) -> Void

  struct Details {
    let name: String
    let avatarImageName: String?
  }

  @Published var name: String
  @Published var avatarImageName: String?

  let primaryActionsViewModel = PrimaryActionsViewModel()

  let configuredSource: ConfiguredSource
  let nextHandler: NextHandler

  init(configuredSource: ConfiguredSource, nextHandler: @escaping NextHandler) {
    self.name = configuredSource.model.name
    self.configuredSource = configuredSource
    self.nextHandler = nextHandler

    $name
      .map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .map { isValid in
        return PrimaryActionsButton(title: "Add", disabled: !isValid) { [weak self] in
          self?.next()
        }
      }
      .assign(to: &primaryActionsViewModel.$continueButton)
  }

  func generateName() {
    if let generatedName = SourceNameGenerator.default.generateName(for: configuredSource.model) {
      name = generatedName
    }
  }

  func next() {
    nextHandler(Details(name: name, avatarImageName: avatarImageName))
  }
}
