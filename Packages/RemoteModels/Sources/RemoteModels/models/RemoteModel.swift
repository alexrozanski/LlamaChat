//
//  RemoteModel.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public struct RemoteModel: Decodable {
  public enum Source {
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
  public let publisher: RemoteModelPublisher
  public let variants: [RemoteModelVariant]

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

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    name = try values.decode(String.self, forKey: .name)
    description = try values.decode(String.self, forKey: .description)

    let source = try values.decode(String.self, forKey: .source)
    switch source {
    case "local":
      self.source = .local
    case "remote":
      self.source = .remote
    default:
      throw DecodingError.typeMismatch(Source.self, DecodingError.Context(codingPath: [CodingKeys.source], debugDescription: "unsupported source '\(source)'"))
    }
    sourcingDescription = try values.decodeIfPresent(String.self, forKey: .sourcingDescription)

    format = try values.decode([String].self, forKey: .format)
    legacy = try values.decodeIfPresent(Bool.self, forKey: .legacy) ?? false
    languages = try values.decode([String].self, forKey: .languages)
    publisher = try values.decode(RemoteModelPublisher.self, forKey: .publisher)
    variants = try values.decode([RemoteModelVariant].self, forKey: .variants)
  }

  public init(
    id: String,
    name: String,
    description: String,
    source: Source,
    sourcingDescription: String?,
    format: [String],
    legacy: Bool,
    languages: [String],
    publisher: RemoteModelPublisher,
    variants: [RemoteModelVariant]
  ) {
    self.id = id
    self.name = name
    self.description = description
    self.source = source
    self.sourcingDescription = sourcingDescription
    self.format = format
    self.legacy = legacy
    self.languages = languages
    self.publisher = publisher
    self.variants = variants
  }
}
