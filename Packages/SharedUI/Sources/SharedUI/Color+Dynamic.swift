//
//  Color+Dynamic.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import Foundation
import SwiftUI

public extension Color {
  init(light: @autoclosure @escaping () -> Color, dark: @autoclosure @escaping () -> Color) {
    self.init(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
      switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
      case .some(.darkAqua):
        return NSColor(dark())
      default:
        return NSColor(light())
      }
    }))
  }

  init(lightNsColor: @autoclosure @escaping () -> NSColor, darkNsColor: @autoclosure @escaping () -> NSColor) {
    self.init(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
      switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
      case .some(.darkAqua):
        return darkNsColor()
      default:
        return lightNsColor()
      }
    }))
  }
}
