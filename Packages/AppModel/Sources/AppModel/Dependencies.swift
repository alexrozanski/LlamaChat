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
  public let metadataModel: MetadataModel
  public let stateRestoration: StateRestoration

  public init(
    modelParametersViewModelBuilder: @escaping ChatModel.ModelParametersViewModelBuilder
  ) {
    let metadataModel = MetadataModel()
    self.metadataModel = metadataModel
    chatSourcesModel = ChatSourcesModel(metadataModel: metadataModel)
    messagesModel = MessagesModel()
    chatModels = ChatModels(messagesModel: messagesModel, modelParametersViewModelBuilder: modelParametersViewModelBuilder)
    stateRestoration = StateRestoration()
  }
}
