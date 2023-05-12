//
//  SourceViewModel.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import CardUI
import DataModel

class SourceViewModel {
  enum SelectionType {
    case model
    case variant
  }

  var id: String { return model.id }
  var name: String { return model.name }
  var description: String { return model.description }

  var languages: [Language] {
    return model.languages.compactMap { code in
      guard let languageString = Locale.current.localizedString(forLanguageCode: code) else { return nil }
      return Language(code: code, label: languageString)
    }
  }

  var publisher: String { return model.publisher.name }

  let model: Model
  private let selectionHandler: (ModelVariant?) -> Void

  @Published var variantRows: [SelectableCardContentRowViewModel]

  init(model: Model, matches: [SourceFilterMatch]?, selectionHandler: @escaping (ModelVariant?) -> Void) {
    self.model = model

    // Default to true because nil matches means we're not filtering by anything.
    let matchesModel = matches?.matchesModel(id: model.id) ?? true

    self.selectionHandler = selectionHandler
    self.variantRows = []

    variantRows = model
      .variants
      .filter { variant in
        matchesModel ? true : (matches?.matchesVariant(variantId: variant.id, modelId: model.id) ?? false)
      }
      .map { variant in
        SelectableCardContentRowViewModel(
          id: variant.id,
          label: variant.name,
          icon: "point.3.connected.trianglepath.dotted",
          description: variant.description,
          selectionHandler: { [weak self] in
            self?.select(variant: variant)
          }
        )
      }
  }

  var isRemote: Bool {
    return model.downloadable
  }

  var selectionType: SelectionType {
    if isRemote {
      return .variant
    } else {
      return .model
    }
  }

  var isModelSelectable: Bool {
    switch selectionType {
    case .model: return true
    case .variant: return false
    }
  }

  var hasSelectableVariants: Bool {
    switch selectionType {
    case .model: return false
    case .variant: return true
    }
  }


  func select() {
    guard isModelSelectable else { return }
    select(variant: nil)
  }

  func select(variant: ModelVariant?) {
    selectionHandler(variant)
  }
}
