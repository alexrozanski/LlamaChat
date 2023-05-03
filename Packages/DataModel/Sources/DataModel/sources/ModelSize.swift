//
//  ModelSize.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation

public enum ModelSize: String, Codable, Hashable, Identifiable {
  case unknown
  case size7B
  case size13B
  case size30B
  case size65B

  public var id: String {
    return rawValue
  }

  public var isUnknown: Bool {
    switch self {
    case .unknown:
      return true
    case .size7B, .size13B, .size30B, .size65B:
      return false
    }
  }
}
