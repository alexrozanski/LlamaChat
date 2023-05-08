//
//  ModelPublisher.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public struct ModelPublisher: Codable {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}
