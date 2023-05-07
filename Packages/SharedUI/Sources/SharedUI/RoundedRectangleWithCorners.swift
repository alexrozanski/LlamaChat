//
//  RoundedRectangleWithCorners.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 05/05/2023.
//

import SwiftUI

public struct RoundedRectangleWithCorners: Shape {
  public struct Corner: OptionSet {
    public let rawValue: Int

    public static let topLeft = Corner(rawValue: 1 << 0)
    public static let topRight = Corner(rawValue: 1 << 1)
    public static let bottomRight = Corner(rawValue: 1 << 2)
    public static let bottomLeft = Corner(rawValue: 1 << 3)

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    public var bezierPathCorners: NSBezierPath.Corner {
      var corners = NSBezierPath.Corner()
      if contains(.topLeft) {
        corners.insert(.topLeft)
      }
      if contains(.topRight) {
        corners.insert(.topRight)
      }
      if contains(.bottomRight) {
        corners.insert(.bottomRight)
      }
      if contains(.bottomLeft) {
        corners.insert(.bottomLeft)
      }
      return corners
    }
  }

  public let radius: CGFloat
  public let corners: Corner

  public init(radius: CGFloat, corners: Corner) {
    self.radius = radius
    self.corners = corners
  }

  public func path(in rect: CGRect) -> Path {
    return Path(NSBezierPath(roundedRect: rect, corners: corners.bezierPathCorners, cornerRadius: radius))
  }
}
