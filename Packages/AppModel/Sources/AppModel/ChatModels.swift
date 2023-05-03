//
//  ChatModels.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation
import DataModel

public class ChatModels: ObservableObject {
  let messagesModel: MessagesModel

  private var models: [ChatModel] = []

  public init(messagesModel: MessagesModel) {
    self.messagesModel = messagesModel
  }

  public func chatModel(for source: ChatSource) -> ChatModel {
    if let existingModel = models.first(where: { $0.source.id == source.id }) {
      return existingModel
    }

    let newModel = ChatModel(source: source, messagesModel: messagesModel)
    models.append(newModel)
    return newModel
  }
}
