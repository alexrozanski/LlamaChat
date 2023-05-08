//
//  ModelProvider.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation

public protocol ModelProvider {
  func provideModels(modelId: String, variantId: String?) -> (model: Model?, variant: ModelVariant?)
}
