//
//  SettingsWindowViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit
import Combine

class SettingsViewModel: ObservableObject {
  private let chatSources: ChatSources

  lazy var sourcesSettingsViewModel = SourcesSettingsViewModel(chatSources: chatSources)

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
  }
}
