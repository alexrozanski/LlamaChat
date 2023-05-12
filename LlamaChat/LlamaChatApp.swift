//
//  CamelApp.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI
import AppModel
import ChatUI
import DataModel
import Downloads
import ModelCompatibilityUI
import ModelDirectory
import SettingsUI
import SharedUI

class LlamaChatAppDelegate: NSObject, NSApplicationDelegate {
  var dependencies: Dependencies?

  func applicationDidFinishLaunching(_ notification: Notification) {
    ModelFileManager.shared.cleanUpUnquantizedModelFiles()
    DownloadsManager.shared.cleanUp()

    dependencies?.metadataModel.fetchMetadata()
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
    let dependencies = Dependencies(
      modelParametersViewModelBuilder: { modelParameters, chatModel in
        return makeParametersViewModel(from: modelParameters, chatModel: chatModel)
      }
    )
    let settingsViewModel = SettingsViewModel(dependencies: dependencies)

    _dependencies = StateObject(wrappedValue: dependencies)
    _mainChatViewModel = StateObject(wrappedValue: MainChatViewModel(dependencies: dependencies))
    _settingsViewModel = StateObject(wrappedValue: settingsViewModel)

    // For deeplinking
    SettingsWindowPresenter.shared.settingsViewModel = settingsViewModel

    appDelegate.dependencies = dependencies
  }

  var body: some Scene {
    Settings {
      SettingsView(viewModel: settingsViewModel) { parametersViewModel in
        ParametersSettingsView(viewModel: parametersViewModel)
      }
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
