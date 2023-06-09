//
//  FileUtils.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

func applicationSupportDirectoryURL() -> URL? {
  guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return nil }

  do {
    let url = try FileManager().url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let appScopedDirectory = url.appendingPathComponent(bundleIdentifier, isDirectory: true)

    if !FileManager.default.fileExists(atPath: appScopedDirectory.path) {
      try FileManager.default.createDirectory(at: appScopedDirectory, withIntermediateDirectories: false)
    }
    return appScopedDirectory
  } catch {
    print("Error getting application support directory:", error)
    return nil
  }
}
