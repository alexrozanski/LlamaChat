//
//  SourceViewModel.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import ModelMetadata

class SourceViewModel {
  enum SelectionType {
    case model
    case variant
  }

  var id: String { return model.id }
  var name: String { return model.name }
  var description: String { return model.description }
  var publisher: String { return model.publisher.name }
  let variants: [VariantViewModel]

  private let model: Model
  private let selectionHandler: (ModelVariant?) -> Void

  init(
    model: Model,
    matches: [SourceFilterMatch]?,
    selectionHandler: @escaping (ModelVariant?) -> Void
  ) {
    self.model = model
    self.selectionHandler = selectionHandler

    // Default to true because nil matches means we're not filtering by anything.
    let matchesModel = matches?.matchesModel(id: model.id) ?? true
    self.variants = model
      .variants
      .filter { variant in
        matchesModel ? true : (matches?.matchesVariant(variantId: variant.id, modelId: model.id) ?? false)
      }
      .map { variant in
        VariantViewModel(model: variant, selectionHandler: { selectionHandler(variant) })
      }
  }

  var isRemote: Bool {
    switch model.source {
    case .local:
      return false
    case .remote:
      return true
    }
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
    selectionHandler(nil)
  }
}

class VariantViewModel {
  var id: String { return model.id }
  var name: String { return model.name }
  var description: String? { return model.description }

  private let model: ModelVariant
  private let selectionHandler: () -> Void

  init(model: ModelVariant, selectionHandler: @escaping () -> Void) {
    self.model = model
    self.selectionHandler = selectionHandler
  }

  func select() {
    selectionHandler()
  }
}
