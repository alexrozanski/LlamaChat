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
  public let parameters: ModelParameterSize?
  public let engine: String
  public let downloadUrl: URL?

  public enum CodingKeys: CodingKey {
    case id
    case name
    case description
    case parameters
    case engine
    case downloadUrl
  }

  public init(
    id: String,
    name: String,
    description: String?,
    parameters: ModelParameterSize?,
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

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.description = try container.decodeIfPresent(String.self, forKey: .description)
    self.parameters = try container.decodeIfPresent(ModelParameterSize.self, forKey: .parameters)
    self.engine = try container.decode(String.self, forKey: .engine)
    self.downloadUrl = try container.decodeIfPresent(URL.self, forKey: .downloadUrl)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encodeIfPresent(description, forKey: .description)
    try container.encodeIfPresent(parameters, forKey: .parameters)
    try container.encode(engine, forKey: .engine)
    try container.encodeIfPresent(downloadUrl, forKey: .downloadUrl)
  }
}
