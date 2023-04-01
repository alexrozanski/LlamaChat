//
//  SourcesSettingsViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine

class SourcesSettingsViewModel: ObservableObject {
  private let chatSources: ChatSources

  @Published var sources: [ChatSource]
  @Published var selectedSource: ChatSource?

  private var subscriptions = Set<AnyCancellable>()

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
    self.sources = chatSources.sources
    chatSources.$sources.sink(receiveValue: { sources in
      self.sources = sources
    }).store(in: &subscriptions)
  }
}
