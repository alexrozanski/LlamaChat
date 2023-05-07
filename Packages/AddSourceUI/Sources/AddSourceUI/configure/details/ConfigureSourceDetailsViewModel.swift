//
//  ConfigureSourceDetailsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import AppModel
import RemoteModels

class ConfigureSourceDetailsViewModel: ObservableObject {
  @Published var name: String
  @Published var avatarImageName: String?

  let model: RemoteModel

  init(defaultName: String? = nil, model: RemoteModel) {
    self.name = defaultName ?? ""
    self.model = model
  }

  func generateName() {
    if let generatedName = SourceNameGenerator.default.generateName(for: model) {
      name = generatedName
    }
  }
}
