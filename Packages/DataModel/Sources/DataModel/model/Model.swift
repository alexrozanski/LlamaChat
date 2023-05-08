//
//  Model.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public struct Model: Codable {
  public enum Source: String,
                      Codable {
    case local
    case remote
  }

  public let id: String
  public let name: String
  public let description: String
  public let source: Source
  public let sourcingDescription: String?
  public let format: [String]
  public let languages: [String]
  public let legacy: Bool
  public let publisher: ModelPublisher
  public let variants: [ModelVariant]

  public enum CodingKeys: CodingKey {
    case id
    case name
    case description
    case source
    case sourcingDescription
    case format
    case legacy
    case languages
    case publisher
    case variants
  }

  public init(
    id: String,
    name: String,
    description: String,
    source: Source,
    sourcingDescription: String?,
    format: [String],
    languages: [String],
    legacy: Bool,
    publisher: ModelPublisher,
    variants: [ModelVariant]
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.source = source
    self.sourcingDescription = sourcingDescription
    self.format = format
    self.languages = languages
    self.legacy = legacy
    self.publisher = publisher
    self.variants = variants
  }
}
