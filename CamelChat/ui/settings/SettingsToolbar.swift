//
//  SettingsToolbar.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit

extension NSToolbar {
  static let settings: NSToolbar = {
    let toolbar = NSToolbar(identifier: "SettingsToolbar")
    toolbar.displayMode = .iconAndLabel
    toolbar.allowsUserCustomization = false
    return toolbar
  }()
}

class SettingsToolbarDelegate: NSObject, NSToolbarDelegate {
  let model: SettingsToolbarModel

  init(model: SettingsToolbarModel) {
    self.model = model
  }

  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return model.allItemIdentifiers
  }

  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return model.allItemIdentifiers
  }

  func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    return model.allItemIdentifiers
  }

  func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
    guard let item = model.item(for: itemIdentifier) else { return nil }

    let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
    toolbarItem.label = item.label
    toolbarItem.image = item.icon
    toolbarItem.paletteLabel = item.label
    toolbarItem.toolTip = item.toolTip
    toolbarItem.target = self
    toolbarItem.action = #selector(toolbarItemAction(_:))
    return toolbarItem
  }

  @IBAction func toolbarItemAction(_ sender: Any) {
    guard let sender = sender as? NSToolbarItem else { return }
    model.selectItem(with: sender.itemIdentifier)
  }
}

fileprivate extension SettingsToolbarModel {
  var allItemIdentifiers: [NSToolbarItem.Identifier] {
    return items.map { $0.toolbarItemIdentifier }
  }
}
