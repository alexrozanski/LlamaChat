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
}
