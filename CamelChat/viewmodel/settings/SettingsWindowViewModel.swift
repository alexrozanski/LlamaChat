//
//  SettingsWindowViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit
import Combine

class SettingsWindowViewModel: ObservableObject {
  enum Tab {
    case sources
  }

  @Published var selectedTab: Tab?

  private let model: SettingsToolbarModel
  private let chatSources: ChatSources

  private var subscriptions = Set<AnyCancellable>()

  lazy var sourcesSettingsViewModel = SourcesSettingsViewModel(chatSources: chatSources)

  init(model: SettingsToolbarModel, chatSources: ChatSources) {
    self.model = model
    self.chatSources = chatSources
    model.$selectedItem.sink(receiveValue: { toolbarItem in
      self.selectedTab = toolbarItem?.tab
    }).store(in: &subscriptions)
  }

  func select(tab: Tab) {
    selectedTab = tab
    model.selectItem(with: tab.toolbarItemIdentifier)
  }
}

fileprivate extension SettingsToolbarModel.ToolbarItem {
  var tab: SettingsWindowViewModel.Tab {
    switch self {
    case .sources: return .sources
    }
  }
}

fileprivate extension SettingsWindowViewModel.Tab {
  var toolbarItemIdentifier: NSToolbarItem.Identifier {
    switch self {
    case .sources: return SettingsToolbarModel.ToolbarItem.sources.toolbarItemIdentifier
    }
  }
}
