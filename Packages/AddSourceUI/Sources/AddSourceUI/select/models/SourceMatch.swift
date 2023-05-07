//
//  SourceMatch.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation

enum SourceFilterMatch {
  case modelName(id: String)
  case modelLocation
  case variantName(modelId: String, variantId: String)
}

extension Array where Element == SourceFilterMatch {
  func matchesModel(id: String) -> Bool {
    return first { match in
      switch match {
      case .modelName(id: let modelId):
        return modelId == id
      case .variantName, .modelLocation:
        return false
      }
    } != nil
  }

  func matchesVariant(variantId: String, modelId: String) -> Bool {
    return first { match in
      switch match {
      case .variantName(modelId: let matchModelId, variantId: let matchVariantId):
        return modelId == matchModelId && variantId == matchVariantId
      case .modelName, .modelLocation:
        return false
      }
    } != nil
  }
}
