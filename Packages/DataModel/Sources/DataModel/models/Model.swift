//
//  Model.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public class Model: ObservableObject {
  public let name: String

  public init(name: String) {
    self.name = name
  }
}
