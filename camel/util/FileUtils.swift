//
//  FileUtils.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation

func applicationSupportDirectoryURL() -> URL? {
  return try? FileManager().url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}
