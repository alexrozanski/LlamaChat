//
//  CamelApp.swift
//  Camel
//
//  Created by Alex Rozanski on 28/03/2023.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSToolbarDelegate {
  private lazy var chatSources = ChatSources()
  private lazy var setupViewModel = SetupViewModel(chatSources: chatSources)

  private lazy var setupWindowController: NSWindowController = {
    let hostingController = NSHostingController(rootView: SetupWindowContentView(viewModel: setupViewModel))
    let window = NSWindow(contentViewController: hostingController)
    window.title = "Setup"
    window.styleMask = [.titled, .closable, .miniaturizable]
    window.setContentSize(NSSize(width: 600, height: 400))
    let windowController = NSWindowController(window: window)
    windowController.windowFrameAutosaveName = "setup"
    return windowController
  }()

  private lazy var chatWindowController: NSWindowController = {
    let hostingController = NSHostingController(rootView: ChatWindowContentView(viewModel: ChatSourcesViewModel(chatSources: self.chatSources)))
    let window = NSWindow(contentViewController: hostingController)
    window.title = "Chat"
    window.styleMask = [.titled, .closable, .resizable, .miniaturizable, .fullSizeContentView]
    window.setContentSize(NSSize(width: 600, height: 400))
    let windowController = NSWindowController(window: window)
    windowController.windowFrameAutosaveName = "chat"
    return windowController
  }()

  private lazy var settingsToolbarModel = SettingsToolbarModel(toolbar: .settings)
  private lazy var settingsWindowViewModel = SettingsWindowViewModel(model: settingsToolbarModel, chatSources: chatSources)
  private lazy var settingsToolbarDelegate = SettingsToolbarDelegate(model: settingsToolbarModel)

  private lazy var settingsWindowController: NSWindowController = {
    let hostingController = NSHostingController(rootView: SettingsWindowContentView(viewModel: settingsWindowViewModel))

    // See https://github.com/billibala/SUIToolbarPlay/blob/master/SUIToolbarPlay/AppDelegate.swift#L21
    NSToolbar.settings.delegate = settingsToolbarDelegate

    let window = NSWindow(contentViewController: hostingController)
    window.title = "Settings"
    window.styleMask = [.titled, .closable, .resizable, .miniaturizable]
    window.setContentSize(NSSize(width: 750, height: 500))
    window.toolbarStyle = .preference
    window.toolbar = .settings

    let windowController = NSWindowController(window: window)
    windowController.windowFrameAutosaveName = "settings"

    return windowController
  }()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if chatSources.sources.isEmpty {
      showSetupWindow()
    } else {
      showChatWindow()
    }
  }

  private func showSetupWindow() {
    setupViewModel.start()
    setupWindowController.showWindow(self)
  }

  private func showChatWindow() {
    chatWindowController.showWindow(self)
  }

  @IBAction func showSettingsWindow(_ sender: Any) {
    settingsWindowController.showWindow(self)
  }
}
