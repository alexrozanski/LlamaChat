//
//  ModelStat.swift
//  
//
//  Created by Alex Rozanski on 10/05/2023.
//

import Foundation

public enum ModelStat<V> {
  case none
  case unknown
  case loading
  case value(V)

  public func map<U>(_ transform: (_ value: V) -> ModelStat<U>) -> ModelStat<U> {
    switch self {
    case .none: return .none
    case .unknown: return .unknown
    case .loading: return .loading
    case .value(let value): return transform(value)
    }
  }

  public var value: V? {
    switch self {
    case .none, .unknown, .loading:
      return nil
    case .value(let value):
      return value
    }
  }
}
