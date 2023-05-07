//
//  SourceNameGenerator.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation
import RemoteModels

fileprivate struct Names: Decodable {
  let llamaNames: [String]
  let alpacaNames: [String]
}

public class SourceNameGenerator {
  private lazy var names: Names? = {
    guard let fileURL = Bundle.main.url(forResource: "names", withExtension: "json") else { return nil }

    do {
      let data = try Data(contentsOf: fileURL)
      return try JSONDecoder().decode(Names.self, from: data)
    } catch {
      print("Error loading source names:", error)
      return nil
    }
  }()

  public static let `default` = SourceNameGenerator()
  private init() {}

  public var canGenerateNames: Bool {
    return names != nil
  }

  public func generateName(for model: RemoteModel) -> String? {
    guard let names else { return nil }

    switch model.id {
    case "llama":
      return names.llamaNames.randomElement()
    case "alpaca":
      return names.alpacaNames.randomElement()
    default:
      var all = names.alpacaNames
      all.append(contentsOf: names.llamaNames)
      return all.randomElement()
    }
  }
}
