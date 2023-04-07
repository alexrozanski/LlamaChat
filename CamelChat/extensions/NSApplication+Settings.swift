//
//  NSApplication+Settings.swift
//  CamelChat
//
//  Created by Alex Rozanski on 07/04/2023.
//

import AppKit

extension NSApplication {
  func showSettingsWindow() {
    if #available(macOS 13.0, *) {
      sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    else {
      sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
    }
  }
}
