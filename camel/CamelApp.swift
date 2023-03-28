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

  var body: some Scene {
    WindowGroup {
      ContentView(chatModel: chatModel)
    }
  }
}
