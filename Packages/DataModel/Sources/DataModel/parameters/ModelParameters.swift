//
//  ModelParameters.swift
//  
//
//  Created by Alex Rozanski on 08/05/2023.
//

import Foundation
import Combine

public protocol ModelParameters: ObservableObject {}

public final class AnyModelParameters: ObservableObject {
  private let _objectWillChange: () -> AnyPublisher<Void, Never>
  private let _wrapped: () -> any ModelParameters

  public var objectWillChange: AnyPublisher<Void, Never> {
    _objectWillChange()
  }

  public var wrapped: any ModelParameters {
    _wrapped()
  }

  public init<P: ModelParameters>(_ parameters: P) {
    _objectWillChange = { parameters.objectWillChange.map { _ in }.eraseToAnyPublisher() }
    _wrapped = { return parameters }
  }
}

public final class EmptyModelParameters: ModelParameters {
  public init() {}
}
