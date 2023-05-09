//
//  ModelVariant.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation

public struct ModelVariant: Codable {
  public let id: String
  public let name: String
  public let description: String?
  public let parameters: String?
  public let engine: String
  public let downloadUrl: URL?

  public init(
    id: String,
    name: String,
    description: String?,
    parameters: String?,
    engine: String,
    downloadUrl: URL?
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.parameters = parameters
    self.engine = engine
    self.downloadUrl = downloadUrl
  }
}
