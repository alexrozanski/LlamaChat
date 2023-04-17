//
//  SettingsWindowPresenter.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 17/04/2023.
//

import AppKit

class SettingsWindowPresenter {
  enum Deeplink {
    case general
    case sources(sourceId: ChatSource.ID?)
  }

  static let shared = SettingsWindowPresenter()

  var settingsViewModel: SettingsViewModel?

  private init() {}

  func present() {
    present(deeplinkingTo: nil)
  }

  func present(deeplinkingTo deeplink: Deeplink?) {
    if #available(macOS 13.0, *) {
      NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    else {
      NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }

    // Not sure if this is a bug in SwiftUI but the Settings {} window is never cleaned up
    // so it's safe to just set this directly on settingsViewModel -- the change will be
    // picked up when the settings window is opened.
    if let deeplink {
      switch deeplink {
      case .general:
        settingsViewModel?.selectedTab = .general
      case .sources(sourceId: let sourceId):
        settingsViewModel?.selectSourceInSourcesTab(forSourceWithId: sourceId)
      }
    }
  }
}
