//
//  CamelApp.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

fileprivate struct Dependencies {
  let chatSources = ChatSources()
  let messagesModel = MessagesModel()
  let stateRestoration = StateRestoration()

  static let shared = Dependencies()

  private init() {}
}

class CamelChatAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
  func applicationDidFinishLaunching(_ notification: Notification) {
    if Dependencies.shared.chatSources.sources.isEmpty {
      if let url = URL(string: "camelChat://setup") {
        NSWorkspace.shared.open(url)
      }
    }
  }
}

@main
struct CamelChatApp: App {
  @NSApplicationDelegateAdaptor private var appDelegate: CamelChatAppDelegate

  @StateObject var chatWindowContentViewModel: ChatWindowContentViewModel = ChatWindowContentViewModel(
    chatSources: Dependencies.shared.chatSources,
    messagesModel: Dependencies.shared.messagesModel,
    stateRestoration: Dependencies.shared.stateRestoration
  )
  @StateObject var settingsViewModel = SettingsViewModel(chatSources: Dependencies.shared.chatSources)
  @StateObject var setupViewModel = SetupViewModel(chatSources: Dependencies.shared.chatSources)

  var body: some Scene {
    Settings {
      SettingsView(viewModel: settingsViewModel)
    }
    .windowToolbarStyle(.expanded)
    Window("Chat", id: "chat") {
      ChatWindowContentView(viewModel: chatWindowContentViewModel)
    }
    WindowGroup("Setup") {
      SetupView(viewModel: setupViewModel)
    }
    .windowToolbarStyle(.unified)
    .handlesExternalEvents(matching: Set(arrayLiteral: "setup"))
  }
}
