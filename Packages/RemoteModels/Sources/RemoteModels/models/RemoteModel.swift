//
//  RemoteModel.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public struct RemoteModel: Codable {
  public let name: String
  public let source: String
  public let engine: String
  public let languages: [String]
  public let publisher: RemoteModelPublisher
}
