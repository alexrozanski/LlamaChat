//
//  MetadataFetcher.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import DataModel

protocol MetadataFetcher {
  // If metadata is cached between runs in a deterministic location, returns this location.
  var cachedMetadataURL: URL? { get }

  // Updates metadata and returns the root directory the metadata files are stored in.
  func fetchUpdatedMetadata() async throws -> URL
}
