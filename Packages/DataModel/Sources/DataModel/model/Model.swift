//
//  ModelMetadata.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public struct Model: Codable {
  public enum Source: String {
    case local
    case remote
  }

  public enum Family: String {
    case llama
    case gptj
  }

  public let id: String
  public let name: String
  public let description: String
  public let source: Source
  public let sourcingDescription: String?
  public let family: Family
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
    case family
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
    family: Family,
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
    self.family = family
    self.format = format
    self.languages = languages
    self.legacy = legacy
    self.publisher = publisher
    self.variants = variants
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    name = try values.decode(String.self, forKey: .name)
    description = try values.decode(String.self, forKey: .description)
    source = try decodeSource(from: values)
    sourcingDescription = try values.decodeIfPresent(String.self, forKey: .sourcingDescription)
    family = try decodeFamily(from: values)
    format = try values.decode([String].self, forKey: .format)
    legacy = try values.decodeIfPresent(Bool.self, forKey: .legacy) ?? false
    languages = try values.decode([String].self, forKey: .languages)
    publisher = try values.decode(ModelPublisher.self, forKey: .publisher)
    variants = try values.decode([ModelVariant].self, forKey: .variants)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(name, forKey: .name)
    try container.encode(description, forKey: .description)
    try container.encode(source.rawValue, forKey: .source)
    try container.encode(sourcingDescription, forKey: .sourcingDescription)
    try container.encode(family.rawValue, forKey: .family)
    try container.encode(format, forKey: .format)
    try container.encode(legacy, forKey: .legacy)
    try container.encode(languages, forKey: .languages)
    try container.encode(publisher, forKey: .publisher)
    try container.encode(variants, forKey: .variants)
  }
}

private func decodeSource(from container: KeyedDecodingContainer<Model.CodingKeys>) throws -> Model.Source {
  let source = try container.decode(String.self, forKey: .source)
  switch source {
  case "local":
    return .local
  case "remote":
    return .remote
  default:
    throw DecodingError.typeMismatch(Model.Source.self, DecodingError.Context(codingPath: [Model.CodingKeys.source], debugDescription: "unsupported source '\(source)'"))
  }
}

private func decodeFamily(from container: KeyedDecodingContainer<Model.CodingKeys>) throws -> Model.Family {
  let family = try container.decode(String.self, forKey: .family)
  switch family {
  case "llama":
    return .llama
  case "gptj":
    return .gptj
  default:
    throw DecodingError.typeMismatch(Model.Family.self, DecodingError.Context(codingPath: [Model.CodingKeys.family], debugDescription: "unsupported family '\(family)'"))
  }
}
