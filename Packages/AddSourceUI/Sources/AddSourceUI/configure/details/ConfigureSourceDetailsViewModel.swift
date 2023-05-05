//
//  ConfigureSourceDetailsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import AppModel
import DataModel

class ConfigureSourceDetailsViewModel: ObservableObject {
  @Published var name: String
  @Published var avatarImageName: String?

  private let chatSourceType: ChatSourceType

  init(defaultName: String? = nil, chatSourceType: ChatSourceType) {
    self.name = defaultName ?? ""
    self.chatSourceType = chatSourceType
  }

  func generateName() {
    if let generatedName = SourceNameGenerator.default.generateName(for: chatSourceType) {
      name = generatedName
    }
  }
}
