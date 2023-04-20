//
//  SettingsWindowViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit

enum SettingsTab {
  case general
  case sources
}

class SettingsViewModel: ObservableObject {
  enum InitialSourcesTab {
    case properties
    case parameters
  }

  private let chatSources: ChatSources

  @Published var selectedTab: SettingsTab = .general

  private(set) lazy var generalSettingsViewModel = GeneralSettingsViewModel()
  private(set) lazy var sourcesSettingsViewModel = SourcesSettingsViewModel(chatSources: chatSources)

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
  }

  func selectSourceInSourcesTab(forSourceWithId sourceId: ChatSource.ID?, initialTab: InitialSourcesTab) {
    selectedTab = .sources
    if let sourceId {
      sourcesSettingsViewModel.selectedSourceId = sourceId
      let tab: SourcesSettingsDetailViewModel.Tab
      switch initialTab {
      case .properties:
        tab = .properties
      case .parameters:
        tab = .parameters
      }
      sourcesSettingsViewModel.detailViewModel?.selectedTab = tab
    }
  }
}
