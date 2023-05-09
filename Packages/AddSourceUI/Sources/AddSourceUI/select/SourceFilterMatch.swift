//
//  SourceFilterMatch.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation

enum SourceFilterMatch {
  case modelName(id: String)
  case variantName(modelId: String, variantId: String)
  case location
  case language
}

extension Array where Element == SourceFilterMatch {
  func matchesModel(id: String) -> Bool {
    return first { match in
      switch match {
      case .modelName(id: let modelId):
        return modelId == id
      case .location, .language:
        // A match on the location or language matches the whole model, not just a variant of it.
        return true
      case .variantName:
        return false
      }
    } != nil
  }

  func matchesVariant(variantId: String, modelId: String) -> Bool {
    return first { match in
      switch match {
      case .variantName(modelId: let matchModelId, variantId: let matchVariantId):
        return modelId == matchModelId && variantId == matchVariantId
      case .modelName, .location, .language:
        return false
      }
    } != nil
  }
}
