//
//  LlamaChatError.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import Foundation

struct LlamaChatError {
  static let domain = "com.alexrozanski.LlamaChat.error"

  enum Code: Int {
    case failedToExecuteConversionStep = -1000
  }

  private init() {}
}
