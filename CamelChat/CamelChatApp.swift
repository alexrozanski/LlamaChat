//
//  CamelApp.swift
//  CamelChat
//
//  Created by Alex Rozanski on 02/04/2023.
//

import SwiftUI

fileprivate class Dependencies {
  private(set) lazy var chatSources = ChatSources()
  private(set) lazy var chatModels = ChatModels(messagesModel: messagesModel)
  private(set) lazy var messagesModel = MessagesModel()
  private(set) lazy var stateRestoration = StateRestoration()

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

enum WindowIdentifier: String {
  case chat
  case setup
  case modelContext
}

@main
struct CamelChatApp: App {
  @NSApplicationDelegateAdaptor private var appDelegate: CamelChatAppDelegate

  @StateObject var mainChatViewModel: MainChatViewModel = MainChatViewModel(
    chatSources: Dependencies.shared.chatSources,
    chatModels: Dependencies.shared.chatModels,
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

    Window("Chat", id: WindowIdentifier.chat.rawValue) {
      MainChatView(viewModel: mainChatViewModel)
    }

    WindowGroup("Setup", id: WindowIdentifier.setup.rawValue) {
      SetupView(viewModel: setupViewModel)
    }
    .windowResizability(.contentSize)
    .windowToolbarStyle(.unified)
    .handlesExternalEvents(matching: Set(arrayLiteral: "setup"))

    WindowGroup("Model Context", id: WindowIdentifier.modelContext.rawValue, for: ChatSource.ID.self) { $chatId in
      ModelContextView(chatSourceId: chatId)
        .environmentObject(Dependencies.shared.chatSources)
        .environmentObject(Dependencies.shared.chatModels)
    }
  }
}
