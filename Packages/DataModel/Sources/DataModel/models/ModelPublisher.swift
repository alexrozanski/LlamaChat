//
//  ModelPublisher.swift
//  
//
//  Created by Alex Rozanski on 04/05/2023.
//

import Foundation

public class ModelPublisher: ObservableObject {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}
