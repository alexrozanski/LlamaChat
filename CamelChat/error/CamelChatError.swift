//
//  CamelChatError.swift
//  CamelChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import Foundation

struct CamelChatError {
  static let domain = "com.alexrozanski.CamelChat.error"

  enum Code: Int {
    case failedToExecuteConversionStep = -1000
  }

  private init() {}
}
