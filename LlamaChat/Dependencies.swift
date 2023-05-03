//
//  Dependencies.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import SwiftUI
import AppModel

class Dependencies: ObservableObject {
  let chatSourcesModel: ChatSourcesModel
  let chatModels: ChatModels
  let messagesModel: MessagesModel
  let remoteMetadataModel: RemoteMetadataModel
  let stateRestoration: StateRestoration

  init() {
    chatSourcesModel = ChatSourcesModel()
    messagesModel = MessagesModel()
    chatModels = ChatModels(messagesModel: messagesModel)
    remoteMetadataModel = RemoteMetadataModel(apiBaseURL: URL(string: "http://localhost:3000/api/")!)
    stateRestoration = StateRestoration()
  }
}
