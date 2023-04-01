//
//  SettingsToolbar.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit

extension NSToolbarItem.Identifier {
  static let sources = NSToolbarItem.Identifier(rawValue: "Sources")
}

extension NSToolbar {
  static let settings: NSToolbar = {
    let toolbar = NSToolbar(identifier: "SettingsToolbar")
    toolbar.displayMode = .iconAndLabel
    toolbar.allowsUserCustomization = false
    return toolbar
  }()
}

class SettingsToolbarDelegate: NSObject, NSToolbarDelegate {
  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    [.sources]
  }

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    [.sources]
  }

  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    switch itemIdentifier {
    case .sources:
      return makeToolbarItem(
        itemIdentifier: .sources,
        label: "Sources",
        image: NSImage(systemSymbolName: "ellipsis.bubble", accessibilityDescription: nil)!,
        toolTip: "Configure model sources"
      )
    default:
      return nil
    }
  }

  func makeToolbarItem(
    itemIdentifier: NSToolbarItem.Identifier,
    label: String,
    image: NSImage,
    toolTip: String
  ) -> NSToolbarItem? {
    let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
    toolbarItem.label = label
    toolbarItem.image = image
    toolbarItem.paletteLabel = label
    toolbarItem.toolTip = toolTip
    toolbarItem.target = self
    toolbarItem.action = #selector(toolbarItemAction(_:))
    return toolbarItem
  }

  @IBAction func toolbarItemAction(_ sender: Any) {

  }
}
