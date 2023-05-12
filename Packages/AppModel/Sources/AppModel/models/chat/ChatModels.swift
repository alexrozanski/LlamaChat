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
  let modelParametersViewModelBuilder: ChatModel.ModelParametersViewModelBuilder

  private var models: [ChatModel] = []

  public init(
    messagesModel: MessagesModel,
    modelParametersViewModelBuilder: @escaping ChatModel.ModelParametersViewModelBuilder
  ) {
    self.messagesModel = messagesModel
    self.modelParametersViewModelBuilder = modelParametersViewModelBuilder
  }

  public func chatModel(for source: ChatSource) -> ChatModel {
    if let existingModel = models.first(where: { $0.source.id == source.id }) {
      return existingModel
    }

    let newModel = ChatModel(
      source: source,
      messagesModel: messagesModel,
      modelParametersViewModelBuilder: modelParametersViewModelBuilder
    )
    models.append(newModel)
    return newModel
  }
}
