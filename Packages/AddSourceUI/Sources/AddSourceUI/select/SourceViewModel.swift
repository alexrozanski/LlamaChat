//
//  SourceViewModel.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import RemoteModels

class SourceViewModel {
  enum SelectionType {
    case model
    case variant
  }

  var id: String { return remoteModel.id }
  var name: String { return remoteModel.name }
  var description: String { return remoteModel.description }
  var publisher: String { return remoteModel.publisher.name }
  let variants: [VariantViewModel]

  private let remoteModel: RemoteModel
  private let selectionHandler: (RemoteModelVariant?) -> Void

  init(
    remoteModel: RemoteModel,
    matches: [SourceFilterMatch]?,
    selectionHandler: @escaping (RemoteModelVariant?) -> Void
  ) {
    self.remoteModel = remoteModel
    self.selectionHandler = selectionHandler

    // Default to true because nil matches means we're not filtering by anything.
    let matchesModel = matches?.matchesModel(id: remoteModel.id) ?? true
    self.variants = remoteModel
      .variants
      .filter { variant in
        matchesModel ? true : (matches?.matchesVariant(variantId: variant.id, modelId: remoteModel.id) ?? false)
      }
      .map { variant in
        VariantViewModel(remoteModel: variant, selectionHandler: { selectionHandler(variant) })
      }
  }

  var isRemote: Bool {
    switch remoteModel.source {
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
  var id: String { return remoteModel.id }
  var name: String { return remoteModel.name }
  var description: String? { return remoteModel.description }

  private let remoteModel: RemoteModelVariant
  private let selectionHandler: () -> Void

  init(remoteModel: RemoteModelVariant, selectionHandler: @escaping () -> Void) {
    self.remoteModel = remoteModel
    self.selectionHandler = selectionHandler
  }

  func select() {
    selectionHandler()
  }
}
