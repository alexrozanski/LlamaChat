//
//  AppSettingsModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 15/04/2023.
//

import Foundation
import FileManager

fileprivate class SerializedAppSettingsPayload: SerializedPayload<AppSettingsModel> {
  override class var valueKey: String? { return "settings" }
  override class var currentPayloadVersion: Int { return 1 }
}

public class AppSettingsModel: ObservableObject, Codable {
  // Number of thrmeads to run prediction on.
  @Published public var numThreads: Int {
    didSet {
      persistSettings()
    }
  }

  public enum CodingKeys: CodingKey {
    case numThreads
  }

  public static let shared: AppSettingsModel = {
    guard
      let settingsFileURL = persistedFileURL,
      FileManager.default.fileExists(atPath: settingsFileURL.path)
    else {
      return makeDefaultSettings()
    }

    do {
      let jsonData = try Data(contentsOf: settingsFileURL)
      let payload = try JSONDecoder().decode(SerializedAppSettingsPayload.self, from: jsonData)
      return payload.value
    } catch {
      print("Error loading sources:", error)
      return makeDefaultSettings()
    }
  }()

  fileprivate init(numThreads: Int) {
    self.numThreads = numThreads
  }

  public required init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    numThreads = try values.decode(Int.self, forKey: .numThreads)
  }

  public func encode(to encoder: Encoder) throws {
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
      let json = try jsonEncoder.encode(SerializedAppSettingsPayload(value: self))
      try json.write(to: persistedFileURL)
    } catch {
      print("Error persisting settings:", error)
    }
  }
}

private func makeDefaultSettings() -> AppSettingsModel {
  return AppSettingsModel(numThreads: ProcessInfo.processInfo.defaultThreadCount)
}
