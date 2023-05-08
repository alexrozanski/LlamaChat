//
//  ChatSourceUpgrader.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation

public enum ChatSourceUpgradeError: Error {
  case invalidChatSourceType
}

public protocol ChatSourceUpgrader {
  func upgradeChatSourceToModel(
    chatSourceType: String,
    modelSize: String
  ) throws -> (modelId: String, modelVariantId: String?)
}
