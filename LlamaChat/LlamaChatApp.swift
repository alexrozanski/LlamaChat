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

@main
struct LlamaChatApp: App {
  @StateObject var chatSources: ChatSources
  @StateObject var chatModels: ChatModels
  @StateObject var messagesModel: MessagesModel
  @StateObject var stateRestoration: StateRestoration

  @StateObject var mainChatViewModel: MainChatViewModel
  @StateObject var settingsViewModel: SettingsViewModel

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

    WindowGroup("Model Context", id: WindowIdentifier.modelContext.rawValue, for: ChatSource.ID.self) { $chatId in
      ModelContextView(chatSourceId: chatId)
        .environmentObject(chatSources)
        .environmentObject(chatModels)
    }
  }
}
