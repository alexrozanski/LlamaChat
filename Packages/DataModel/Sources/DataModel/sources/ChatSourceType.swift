//
//  ChatSourceType.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

public enum ChatSourceType: String, Codable {
  case llama = "llama"
  case alpaca = "alpaca"
  case gpt4All = "gpt4all"

  public var readableName: String {
    switch self {
    case .llama: return "LLaMA"
    case .alpaca: return "Alpaca"
    case .gpt4All: return "GPT4All"
    }
  }
}
