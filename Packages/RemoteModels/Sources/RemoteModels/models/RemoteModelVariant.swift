//
//  RemoteModelVariant.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation

public struct RemoteModelVariant: Decodable {
  public let id: String
  public let name: String
  public let description: String?
  public let parameters: String
  public let engine: String
  public let downloadUrl: URL?
}
