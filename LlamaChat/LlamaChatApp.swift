//
//  CamelApp.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

enum WindowIdentifier: String {
  case chat
  case setup
  case modelContext
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ notification: Notification) {
    DownloadsManager.shared.cleanUp()
  }
}

@main
struct LlamaChatApp: App {
  @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

  @StateObject var chatSources: ChatSources
  @StateObject var chatModels: ChatModels
  @StateObject var messagesModel: MessagesModel
  @StateObject var stateRestoration: StateRestoration

  @StateObject var mainChatViewModel: MainChatViewModel
  @StateObject var settingsViewModel: SettingsViewModel
  @StateObject var checkForUpdatesViewModel = CheckForUpdatesViewModel()

  init() {
    let chatSources = ChatSources()
    let messagesModel = MessagesModel()
    let chatModels = ChatModels(messagesModel: messagesModel)
    let stateRestoration = StateRestoration()

    _chatSources = StateObject(wrappedValue: chatSources)
    _chatModels = StateObject(wrappedValue: chatModels)
    _messagesModel = StateObject(wrappedValue: messagesModel)
    _stateRestoration = StateObject(wrappedValue: stateRestoration)

    _mainChatViewModel = StateObject(wrappedValue: MainChatViewModel(
      chatSources: chatSources,
      chatModels: chatModels,
      messagesModel: messagesModel,
      stateRestoration: stateRestoration
    ))
    _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(chatSources: chatSources))
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
      CommandGroup(after: .appInfo) {
        Button("Check for Updates…", action: { checkForUpdatesViewModel.checkForUpdates() })
          .disabled(!checkForUpdatesViewModel.canCheckForUpdates)
      }
    }

    WindowGroup("Model Context", id: WindowIdentifier.modelContext.rawValue, for: ChatSource.ID.self) { $chatId in
      ModelContextView(chatSourceId: chatId)
        .environmentObject(chatSources)
        .environmentObject(chatModels)
    }
  }
}
