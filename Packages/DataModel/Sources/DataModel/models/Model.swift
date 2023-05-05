//
//  Model.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public class Model: ObservableObject {
  public let name: String
  public let publisher: ModelPublisher

  public init(name: String, publisher: ModelPublisher) {
    self.name = name
    self.publisher = publisher
  }
}
