//
//  ConfigureSourceDetailsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation

class ConfigureSourceDetailsViewModel: ObservableObject {
  private lazy var nameGenerator = SourceNameGenerator()

  @Published var name: String
  @Published var avatarImageName: String?

  private let chatSourceType: ChatSourceType

  init(defaultName: String? = nil, chatSourceType: ChatSourceType) {
    self.name = defaultName ?? ""
    self.chatSourceType = chatSourceType
  }

  func generateName() {
    if let generatedName = nameGenerator.generateName(for: chatSourceType) {
      name = generatedName
    }
  }
}
