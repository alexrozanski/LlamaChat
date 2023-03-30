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
}
