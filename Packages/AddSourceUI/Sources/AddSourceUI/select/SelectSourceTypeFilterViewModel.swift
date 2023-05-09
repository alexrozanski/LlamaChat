//
//  SelectSourceTypeFilterViewModel.swift
//  
//
//  Created by Alex Rozanski on 05/05/2023.
//

import Foundation

class SelectSourceTypeFilterViewModel: ObservableObject {
  enum Location: String {
    case local
    case remote
  }

  @Published var location: Location?
  @Published var availableLanguages: [Language] = []
  @Published var language: Language?
  @Published var searchFieldText = ""

  @Published private(set) var hasFilters: Bool

  init() {
    location = nil
    language = nil
    hasFilters = false

    $location
      .combineLatest($language)
      .map { location, language in
        return location != nil || language != nil
      }
      .assign(to: &$hasFilters)
  }

  func resetFilters() {
    location = nil
    language = nil
  }
}
