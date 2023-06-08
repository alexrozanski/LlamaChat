//
//  EngineUtils.swift
//  
//
//  Created by Alex Rozanski on 09/06/2023.
//

import Foundation
import DataModel

func engine(for model: Model, variant: ModelVariant?) -> String? {
  if let variant {
    return variant.engine
  }
  return Array(Set(model.variants.map { $0.engine })).first
}
