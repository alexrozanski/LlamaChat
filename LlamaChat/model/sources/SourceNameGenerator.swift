//
//  SourceNameGenerator.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 03/04/2023.
//

import Foundation

fileprivate struct Names: Decodable {
  let llamaNames: [String]
  let alpacaNames: [String]
}

class SourceNameGenerator {
  private lazy var names: Names? = {
    guard
      let fileURL = Bundle.main.url(forResource: "names", withExtension: "json"),
      let data = try? Data(contentsOf: fileURL)
    else { return nil }

    return try? JSONDecoder().decode(Names.self, from: data)
  }()

  var canGenerateNames: Bool {
    return names != nil
  }

  func generateName(for sourceType: ChatSourceType) -> String? {
    guard let names else { return nil }

    switch sourceType {
    case .llama:
      return names.llamaNames.randomElement()
    case .alpaca:
      return names.alpacaNames.randomElement()
    case .gpt4All:
      var all = names.alpacaNames
      all.append(contentsOf: names.llamaNames)
      return all.randomElement()
    }
  }
}
