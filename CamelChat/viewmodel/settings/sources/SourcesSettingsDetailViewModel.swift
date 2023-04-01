//
//  SourcesSettingsDetailViewModel.swift
//  CamelChat
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
    switch source.type {
    case .llama:
      return "LLaMa model"
    case .alpaca:
      return "Alpaca model"
    }
  }
  @Published private(set) var name: String

  private var subscriptions = Set<AnyCancellable>()

  init(source: ChatSource) {
    self.source = source
    modelPath = source.modelURL.path
    name = source.name
    source.$name.sink(receiveValue: { newName in
      self.name = newName
    }).store(in: &subscriptions)
  }

  func updateName(_ newName: String) {
    source.name = newName
  }

  func showModelInFinder() {
    NSWorkspace.shared.activateFileViewerSelecting([source.modelURL])
  }
}
