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

  @StateObject var chatSourcesModel: ChatSourcesModel
  @StateObject var chatModels: ChatModels
  @StateObject var messagesModel: MessagesModel
  @StateObject var stateRestoration: StateRestoration

  @StateObject var mainChatViewModel: MainChatViewModel
  @StateObject var settingsViewModel: SettingsViewModel
  @StateObject var checkForUpdatesViewModel = CheckForUpdatesViewModel()

  init() {
    let chatSourcesModel = ChatSourcesModel()
    let messagesModel = MessagesModel()
    let chatModels = ChatModels(messagesModel: messagesModel)
    let stateRestoration = StateRestoration()
    let settingsViewModel = SettingsViewModel(chatSourcesModel: chatSourcesModel, stateRestoration: stateRestoration)

    _chatSourcesModel = StateObject(wrappedValue: chatSourcesModel)
    _chatModels = StateObject(wrappedValue: chatModels)
    _messagesModel = StateObject(wrappedValue: messagesModel)
    _stateRestoration = StateObject(wrappedValue: stateRestoration)

    _mainChatViewModel = StateObject(wrappedValue: MainChatViewModel(
      chatSourcesModel: chatSourcesModel,
      chatModels: chatModels,
      messagesModel: messagesModel,
      stateRestoration: stateRestoration
    ))
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
        .environmentObject(chatSourcesModel)
        .environmentObject(chatModels)
    }
    // Remove the File > New menu item as this should be opened programmatically.
    .commandsRemoved()
  }
}
