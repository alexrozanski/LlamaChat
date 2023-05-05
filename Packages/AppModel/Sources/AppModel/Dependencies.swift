//
//  Dependencies.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import SwiftUI

public class Dependencies: ObservableObject {
  public let chatSourcesModel: ChatSourcesModel
  public let chatModels: ChatModels
  public let messagesModel: MessagesModel
  public let remoteMetadataModel: RemoteMetadataModel
  public let stateRestoration: StateRestoration

  public init() {
    chatSourcesModel = ChatSourcesModel()
    messagesModel = MessagesModel()
    chatModels = ChatModels(messagesModel: messagesModel)
    remoteMetadataModel = RemoteMetadataModel(apiBaseURL: URL(string: "http://localhost:3000/api/")!)
    stateRestoration = StateRestoration()
  }
}
