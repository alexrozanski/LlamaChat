//
//  ChatSource.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class ChatSource: Codable {
  let name: String
  let type: ChatSourceType
  let modelURL: URL

  init(name: String, type: ChatSourceType, modelURL: URL) {
    self.name = name
    self.type = type
    self.modelURL = modelURL
  }
}
