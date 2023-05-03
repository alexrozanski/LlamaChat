//
//  FileUtils.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

public func applicationSupportDirectoryURL() -> URL? {
  return appScopedPath(for: .applicationSupportDirectory)
}

public func cachesDirectoryURL() -> URL? {
  return appScopedPath(for: .cachesDirectory)
}

func appScopedPath(for searchPathDirectory: FileManager.SearchPathDirectory) -> URL? {
  guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return nil }

  do {
    let url = try FileManager().url(for: searchPathDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let appScopedDirectory = url.appendingPathComponent(bundleIdentifier, isDirectory: true)

    if !FileManager.default.fileExists(atPath: appScopedDirectory.path) {
      try FileManager.default.createDirectory(at: appScopedDirectory, withIntermediateDirectories: false)
    }
    return appScopedDirectory
  } catch {
    print("Error getting app scoped directory for \(searchPathDirectory):", error)
    return nil
  }
}
