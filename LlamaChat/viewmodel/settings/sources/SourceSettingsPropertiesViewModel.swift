//
//  SourceSettingsPropertiesViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 20/04/2023.
//

import AppKit
import Combine
import DataModel

class SourceSettingsPropertiesViewModel: ObservableObject {
  private let source: ChatSource

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

  @Published var useMlock: Bool

  private var subscriptions = Set<AnyCancellable>()

  init(source: ChatSource) {
    self.source = source

    modelPath = source.modelURL.path
    name = source.name
    avatarImageName = source.avatarImageName
    useMlock = source.useMlock

    source.$name.assign(to: &$name)
    $avatarImageName.assign(to: &source.$avatarImageName)

    source.$useMlock.assign(to: &$useMlock)
    $useMlock
      .removeDuplicates()
      .dropFirst()
      .sink { [weak source] in
        source?.useMlock = $0
      }
      .store(in: &subscriptions)
  }

  func updateName(_ newName: String) {
    source.name = newName
  }

  func showModelInFinder() {
    NSWorkspace.shared.activateFileViewerSelecting([source.modelURL])
  }
}
