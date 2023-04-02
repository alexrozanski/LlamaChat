//
//  CamelApp.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

@main
struct CamelApp: App {
  private let chatSources: ChatSources
  private let messagesModel: MessagesModel
  private let stateRestoration: StateRestoration

  @StateObject var chatWindowContentViewModel: ChatWindowContentViewModel
  @StateObject var settingsViewModel: SettingsViewModel
  @StateObject var setupViewModel: SetupViewModel

  init() {
    let chatSources = ChatSources()
    let messagesModel = MessagesModel()
    let stateRestoration = StateRestoration()

    _chatWindowContentViewModel = StateObject(
      wrappedValue: ChatWindowContentViewModel(
        chatSources: chatSources,
        messagesModel: messagesModel,
        stateRestoration: stateRestoration
      )
    )

    _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(chatSources: chatSources))
    _setupViewModel = StateObject(wrappedValue: SetupViewModel(chatSources: chatSources))

    self.chatSources = chatSources
    self.messagesModel = messagesModel
    self.stateRestoration = stateRestoration
  }

  var body: some Scene {
    Settings {
      SettingsView(viewModel: settingsViewModel)
    }
    .windowToolbarStyle(.expanded)
    Window("Chat", id: "chat") {
      ChatWindowContentView(viewModel: chatWindowContentViewModel)
    }
    Window("Setup", id: "setup") {
      SetupWindowContentView(viewModel: setupViewModel)
    }
  }
}
