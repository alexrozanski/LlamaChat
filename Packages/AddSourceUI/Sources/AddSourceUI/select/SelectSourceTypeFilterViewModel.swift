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
  @Published var languages: String?
  @Published var searchFieldText = ""

  @Published private(set) var hasFilters: Bool

  init() {
    location = nil
    languages = nil
    hasFilters = false

    $location
      .combineLatest($languages)
      .map { location, languages in
        return location != nil || languages != nil
      }
      .assign(to: &$hasFilters)
  }

  func resetFilters() {
    location = nil
    languages = nil
  }
}
