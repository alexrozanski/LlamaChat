//
//  ModelParametersViewModel+Init.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import Foundation
import AppModel
import DataModel
import ModelCompatibility

public func makeParametersViewModel(from parameters: AnyModelParameters?, chatModel: ChatModel) -> ModelParametersViewModel? {
  if let parameters = parameters?.wrapped as? LlamaFamilyModelParameters {
    return LlamaFamilyModelParametersViewModel(chatModel: chatModel, parameters: parameters)
  }

  return nil
}
