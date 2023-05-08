//
//  SettingsWindowPresenter.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 17/04/2023.
//

import AppKit
import DataModel

public class SettingsWindowPresenter {
  public enum SourcesTab {
    case properties
    case parameters
  }

  public enum Deeplink {
    case general
    case sources(sourceId: ChatSource.ID?, sourcesTab: SourcesTab)
  }

  public static let shared = SettingsWindowPresenter()

  public var settingsViewModel: SettingsViewModel?

  private init() {}

  public func present() {
    present(deeplinkingTo: nil)
  }

  public func present(deeplinkingTo deeplink: Deeplink?) {
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
      case .sources(sourceId: let sourceId, sourcesTab: let sourcesTab):
        let initialTab: SettingsViewModel.InitialSourcesTab
        switch sourcesTab {
        case .properties:
          initialTab = .properties
        case .parameters:
          initialTab = .parameters
        }
        settingsViewModel?.selectSourceInSourcesTab(forSourceWithId: sourceId, initialTab: initialTab)
      }
    }
  }
}
