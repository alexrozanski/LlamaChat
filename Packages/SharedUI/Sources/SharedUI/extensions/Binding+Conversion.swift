//
//  Binding+Conversion.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import SwiftUI

public extension Binding where Value == UInt {
  func toInt() -> Binding<Int> {
    return Binding<Int>(
      get: { return Int(wrappedValue) },
      set: { wrappedValue = UInt($0) }
    )
  }
}
