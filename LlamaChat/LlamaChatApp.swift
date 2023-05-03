//
//  CamelApp.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI
import AppModel
import DataModel
import ModelDirectory
import RemoteModels

enum WindowIdentifier: String {
  case chat
  case setup
  case modelContext
}

class LlamaChatAppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    ModelFileManager.shared.cleanUpUnquantizedModelFiles()
    DownloadsManager.shared.cleanUp()
  }
}

@main
struct LlamaChatApp: App {
  @NSApplicationDelegateAdaptor var appDelegate: LlamaChatAppDelegate

  @StateObject var dependencies: Dependencies

  @StateObject var mainChatViewModel: MainChatViewModel
  @StateObject var settingsViewModel: SettingsViewModel
  @StateObject var checkForUpdatesViewModel = CheckForUpdatesViewModel()

  init() {
    let dependencies = Dependencies()
    let settingsViewModel = SettingsViewModel(dependencies: dependencies)

    _dependencies = StateObject(wrappedValue: dependencies)
    _mainChatViewModel = StateObject(wrappedValue: MainChatViewModel(dependencies: dependencies))
    _settingsViewModel = StateObject(wrappedValue: settingsViewModel)

    // For deeplinking
    SettingsWindowPresenter.shared.settingsViewModel = settingsViewModel
  }

  var body: some Scene {
    Settings {
      SettingsView(viewModel: settingsViewModel)
    }
    .windowToolbarStyle(.expanded)

    Window("Chat", id: WindowIdentifier.chat.rawValue) {
      MainChatView(viewModel: mainChatViewModel)
    }
    .commands {
      CommandGroup(after: .newItem) {
        Button("New Chat Source", action: {
          mainChatViewModel.presentAddSourceSheet()
        })
        .keyboardShortcut(KeyboardShortcut(KeyEquivalent("n")))
      }
      CommandGroup(after: .appInfo) {
        Button("Check for Updates…", action: { checkForUpdatesViewModel.checkForUpdates() })
          .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
      }
    }

    WindowGroup("Model Context", id: WindowIdentifier.modelContext.rawValue, for: ChatSource.ID.self) { $chatId in
      ModelContextView(chatSourceId: chatId)
        .environmentObject(dependencies)
    }
    // Remove the File > New menu item as this should be opened programmatically.
    .commandsRemoved()
  }
}
