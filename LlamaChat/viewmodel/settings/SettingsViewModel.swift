//
//  SettingsWindowViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit

class SettingsViewModel: ObservableObject {
  private let chatSources: ChatSources

  private(set) lazy var generalSettingsViewModel = GeneralSettingsViewModel()
  private(set) lazy var sourcesSettingsViewModel = SourcesSettingsViewModel(chatSources: chatSources)

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
  }
}
