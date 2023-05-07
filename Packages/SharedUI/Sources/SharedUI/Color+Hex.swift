//
//  Color+Hex.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import SwiftUI

public extension Color {
  init(hex: String, opacity: Double = 1) {
    let scanner = Scanner(string: hex)
    var hexNumber: UInt64 = 0

    _ = scanner.scanString("#")

    if scanner.scanHexInt64(&hexNumber) {
      let red = CGFloat((hexNumber & 0xff0000) >> 16) / 255
      let green = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
      let blue = CGFloat(hexNumber & 0x0000ff) / 255
      self.init(red: Double(red), green: Double(green), blue: Double(blue), opacity: opacity)
    } else {
      self = .gray
    }
  }
}

public extension NSColor {
  convenience init(hex: String, opacity: Double = 1) {
    self.init(Color(hex: hex, opacity: opacity))
  }
}
