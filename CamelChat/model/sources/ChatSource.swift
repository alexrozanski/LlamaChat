//
//  ChatSource.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

class ChatSource: Codable, Equatable {
  let id: String
  let name: String
  let type: ChatSourceType
  let modelURL: URL

  init(name: String, type: ChatSourceType, modelURL: URL) {
    self.id = UUID().uuidString
    self.name = name
    self.type = type
    self.modelURL = modelURL
  }

  static func == (lhs: ChatSource, rhs: ChatSource) -> Bool {
    return lhs.id == rhs.id
  }
}
