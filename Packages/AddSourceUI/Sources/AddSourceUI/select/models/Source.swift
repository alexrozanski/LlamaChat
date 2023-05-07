//
//  Source.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import RemoteModels

struct Source {
  var id: String { return remoteModel.id }
  var name: String { return remoteModel.name }
  var description: String { return remoteModel.description }
  var publisher: String { return remoteModel.publisher.name }
  let variants: [Variant]

  private let remoteModel: RemoteModel
  init(remoteModel: RemoteModel, matches: [SourceFilterMatch]?) {
    self.remoteModel = remoteModel

    // Default to true because nil matches means we're not filtering by anything.
    let matchesModel = matches?.matchesModel(id: remoteModel.id) ?? true
    self.variants = remoteModel
      .variants
      .filter { variant in
        matchesModel ? true : (matches?.matchesVariant(variantId: variant.id, modelId: remoteModel.id) ?? false)
      }
      .map { Variant(remoteModel: $0) }
  }

  var isRemote: Bool {
    switch remoteModel.source {
    case .local:
      return false
    case .remote:
      return true
    }
  }

  var isSourceSelectable: Bool {
    return !isRemote
  }

  var hasSelectableVariants: Bool {
    return isRemote
  }
}

struct Variant {
  var id: String { return remoteModel.id }
  var name: String { return remoteModel.name }
  var description: String? { return remoteModel.description }

  private let remoteModel: RemoteModelVariant
  init(remoteModel: RemoteModelVariant) {
    self.remoteModel = remoteModel
  }
}
