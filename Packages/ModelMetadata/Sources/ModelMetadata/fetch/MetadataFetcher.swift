//
//  MetadataFetcher.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation

protocol MetadataFetcher {
  func updateMetadata() async throws -> [Model]
}
