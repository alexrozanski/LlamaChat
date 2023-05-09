//
//  Language.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import Foundation

struct Language: Hashable, Identifiable {
  let code: String
  let label: String

  var id: String {
    return code
  }

  init(code: String, label: String) {
    self.code = code
    self.label = label
  }

  init?(code: String) {
    guard let label = Locale.current.localizedString(forLanguageCode: code) else { return nil }
    self.init(code: code, label: label)
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(code)
    hasher.combine(label)
  }
}
