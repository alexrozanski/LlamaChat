//
//  Path+NSBezierPath.swift
//  
//
//  Created by Alex Rozanski on 07/05/2023.
//

import SwiftUI

public extension Path {
  init(_ nsBezierPath: NSBezierPath) {
    self.init()

    var points = [NSPoint](repeating: .zero, count: 3)

    for i in 0..<nsBezierPath.elementCount {
      let type = nsBezierPath.element(at: i, associatedPoints: &points)

      switch type {
      case .moveTo:
        self.move(to: CGPoint(x: points[0].x, y: points[0].y))
      case .lineTo:
        self.addLine(to: CGPoint(x: points[0].x, y: points[0].y))
      case .curveTo:
        self.addCurve(to: CGPoint(x: points[2].x, y: points[2].y),
                      control1: CGPoint(x: points[0].x, y: points[0].y),
                      control2: CGPoint(x: points[1].x, y: points[1].y))
      case .closePath:
        self.closeSubpath()
      @unknown default:
        break
      }
    }
  }
}
