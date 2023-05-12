//
//  SourceNameGenerator.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation
import DataModel
import ModelMetadata
import ModelCompatibility

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

  public func generateName(for model: Model) -> String? {
    guard let names else { return nil }

    switch model.id {
    case BuiltinMetadataModels.llama.id:
      return names.llamaNames.randomElement()
    case BuiltinMetadataModels.alpaca.id:
      return names.alpacaNames.randomElement()
    default:
      var all = names.alpacaNames
      all.append(contentsOf: names.llamaNames)
      return all.randomElement()
    }
  }
}
