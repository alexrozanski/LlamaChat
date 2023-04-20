//
//  SourcesSettingsDetailViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit
import Combine

class SourcesSettingsDetailViewModel: ObservableObject {
  private let source: ChatSource

  var id: String { return source.id }
  var modelPath: String

  var type: String {
    return source.type.readableName
  }
  var modelSize: String {
    switch source.modelSize {
    case .unknown:
      return "Unknown"
    case .size7B:
      return "7B"
    case .size13B:
      return "13B"
    case .size30B:
      return "30B"
    case .size65B:
      return "65B"
    }
  }

  @Published private(set) var name: String
  @Published var avatarImageName: String?

  private(set) lazy var parametersViewModel = SourceSettingsParametersViewModel(modelParameters: source.modelParameters)

  private var subscriptions = Set<AnyCancellable>()

  init(source: ChatSource) {
    self.source = source
    modelPath = source.modelURL.path
    name = source.name
    avatarImageName = source.avatarImageName

    source.$name.sink(receiveValue: { [weak self] newName in
      self?.name = newName
    }).store(in: &subscriptions)

    $avatarImageName.sink(receiveValue: { [weak self] newAvatarImageName in
      self?.source.avatarImageName = newAvatarImageName
    }).store(in: &subscriptions)
  }

  func updateName(_ newName: String) {
    source.name = newName
  }

  func showModelInFinder() {
    NSWorkspace.shared.activateFileViewerSelecting([source.modelURL])
  }
}
