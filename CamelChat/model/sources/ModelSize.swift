//
//  ModelSize.swift
//  CamelChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation

enum ModelSize: Codable, Hashable {
  case unknown
  case size7B
  case size12B
  case size30B
  case size65B
}
