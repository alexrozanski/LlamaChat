//
//  ModelParametersCoderProvider.swift
//  
//
//  Created by Alex Rozanski on 09/06/2023.
//

import Foundation

public protocol ModelParametersCoderProvider {
  func modelParametersCoder(for model: Model, variant: ModelVariant?) -> ModelParametersCoder?
}
