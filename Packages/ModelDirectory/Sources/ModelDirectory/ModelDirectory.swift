//
//  ModelDirectory.swift
//  
//
//  Created by Alex Rozanski on 03/05/2023.
//

import Foundation

public class ModelDirectory {
  public typealias ID = String

  public let id: ID
  public let url: URL

  private var hasCleanedUp = false

  init(id: ID, url: URL) {
    self.id = id
    self.url = url
  }

  public func moveFileIntoDirectory(from sourceURL: URL) throws -> URL {
    let dest = url.appending(path: sourceURL.lastPathComponent)
    try FileManager.default.moveItem(at: sourceURL, to: dest)
    return dest
  }

  public func cleanUp() {
    do {
      guard !hasCleanedUp else { return }

      try FileManager.default.removeItem(at: url)
      hasCleanedUp = true
    } catch {
      print("WARNING: failed to clean up model directory")
    }
  }
}
