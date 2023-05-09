//
//  ModelSize.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation

public enum ModelSize: Codable {
  case billions(Decimal)

  public var stringValue: String {
    switch self {
    case .billions(let decimal):
      return "\(NSDecimalNumber(decimal: decimal))B"
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    let scanner = Scanner(string: string)
    guard let decimal = scanner.scanDecimal(), scanner.scanString("B") != nil else {
      throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "value '\(string)' isn't valid"))
    }
    self = .billions(decimal)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(stringValue)
  }
}
