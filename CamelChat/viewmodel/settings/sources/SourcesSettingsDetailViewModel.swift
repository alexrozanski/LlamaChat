//
//  SourcesSettingsDetailViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine

class SourcesSettingsDetailViewModel: ObservableObject {
  private let source: ChatSource

  var modelPath: String

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
}
