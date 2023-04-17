//
//  AppSettings.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 15/04/2023.
//

import Foundation

fileprivate struct Payload: Codable {
  let settings: AppSettings
  var version = 1
}

class AppSettings: ObservableObject, Codable {
  // Number of threads to run prediction on.
  @Published var numThreads: Int {
    didSet {
      persistSettings()
    }
  }

  enum CodingKeys: CodingKey {
    case numThreads
  }

  static let shared: AppSettings = {
    guard
      let settingsFileURL = persistedFileURL,
      FileManager.default.fileExists(atPath: settingsFileURL.path)
    else {
      return makeDefaultSettings()
    }

    do {
      let jsonData = try Data(contentsOf: settingsFileURL)
      let payload = try JSONDecoder().decode(Payload.self, from: jsonData)
      return payload.settings
    } catch {
      print("Error loading sources:", error)
      return makeDefaultSettings()
    }
  }()

  fileprivate init(numThreads: Int) {
    self.numThreads = numThreads
  }

  required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    numThreads = try values.decode(Int.self, forKey: .numThreads)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(numThreads, forKey: .numThreads)
  }

  // MARK: - Persistence

  private static var persistedFileURL: URL? {
    return applicationSupportDirectoryURL()?.appending(path: "appSettings.json")
  }

  private func persistSettings() {
    guard let persistedFileURL = type(of: self).persistedFileURL else { return }

    let jsonEncoder = JSONEncoder()
    do {
      let json = try jsonEncoder.encode(Payload(settings: self))
      try json.write(to: persistedFileURL)
    } catch {
      print("Error persisting settings:", error)
    }
  }
}

private func makeDefaultSettings() -> AppSettings {
  return AppSettings(numThreads: ProcessInfo.processInfo.defaultThreadCount)
}
