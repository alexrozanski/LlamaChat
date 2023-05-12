//
//  ModelParametersCoder.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation

public enum ModelParametersCoderError: Error {
  case unsupportedParameters
}

public protocol ModelParametersCoder {
  func decodeParameters<Key>(
    in container: KeyedDecodingContainer<Key>,
    forKey key: Key
  ) throws -> AnyModelParameters where Key: CodingKey
  
  func encode<Key>(
    parameters: AnyModelParameters,
    to container: inout KeyedEncodingContainer<Key>,
    forKey key: Key
  ) throws where Key: CodingKey
}
