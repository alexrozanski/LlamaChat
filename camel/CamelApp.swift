//
//  CamelApp.swift
//  Camel
//
//  Created by Alex Rozanski on 28/03/2023.
//

import SwiftUI

@main
struct CamelApp: App {
  @StateObject var chatModel = ChatModel()
  @StateObject var chatSources = ChatSources()

  var body: some Scene {
//    WindowGroup {
//      ChatWindowContentView(chatModel: chatModel)
//    }
    Window("Setup", id: "setup") {
      SetupWindowContentView(chatSources: chatSources)
    }
  }
}
