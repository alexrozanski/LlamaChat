//
//  MessageGenerationState.swift
//  Camel
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation

enum MessageGenerationState {
  case none
  case waiting
  case generating
  case cancelled
  case finished
  case error(Error)

  var isError: Bool {
    switch self {
    case .none, .generating, .finished, .cancelled, .waiting:
      return false
    case .error:
      return true
    }
  }

  var isWaiting: Bool {
    switch self {
    case .none, .generating, .finished, .cancelled, .error:
      return false
    case .waiting:
      return true
    }
  }
}
