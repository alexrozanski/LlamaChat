//
//  ChatSourceType.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

enum ChatSourceType: String, CaseIterable, Codable {
  case llama = "llama"
  case alpaca = "alpaca"
  case gpt4All = "gpt4all"

  var readableName: String {
    switch self {
    case .llama: return "LLaMA"
    case .alpaca: return "Alpaca"
    case .gpt4All: return "GPT4All"
    }
  }
}
