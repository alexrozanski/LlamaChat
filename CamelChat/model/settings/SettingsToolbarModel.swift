//
//  SettingsToolbarModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit

class SettingsToolbarModel: ObservableObject {
  enum ToolbarItem: String, CaseIterable {
    case sources

    var toolbarItemIdentifier: NSToolbarItem.Identifier {
      switch self {
      case .sources: return NSToolbarItem.Identifier(rawValue)
      }
    }

    var label: String {
      switch self {
      case .sources: return "Sources"
      }
    }

    var icon: NSImage? {
      switch self {
      case .sources: return NSImage(systemSymbolName: "ellipsis.bubble", accessibilityDescription: nil)
      }
    }

    var toolTip: String? {
      switch self {
      case .sources: return "Configure model sources"
      }
    }

  }

  @Published private(set) var selectedItem: ToolbarItem? {
    didSet {
      toolbar.selectedItemIdentifier = selectedItem?.toolbarItemIdentifier
    }
  }

  var items: [ToolbarItem] = ToolbarItem.allCases

  private let toolbar: NSToolbar

  init(toolbar: NSToolbar) {
    self.toolbar = toolbar
    self.selectedItem = item(for: toolbar.selectedItemIdentifier)
  }

  func item(for identifier: NSToolbarItem.Identifier?) -> ToolbarItem? {
    return items.first { $0.toolbarItemIdentifier == identifier }
  }

  func selectItem(with identifier: NSToolbarItem.Identifier) {
    selectedItem = item(for: identifier)
  }
}
