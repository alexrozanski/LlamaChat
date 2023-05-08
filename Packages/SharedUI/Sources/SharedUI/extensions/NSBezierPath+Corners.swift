//
//  NSBezierPath+Corners.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 05/05/2023.
//

import AppKit

public extension NSBezierPath {
  struct Corner: OptionSet {
    public let rawValue: Int

    public static let topLeft = Corner(rawValue: 1 << 0)
    public static let topRight = Corner(rawValue: 1 << 1)
    public static let bottomRight = Corner(rawValue: 1 << 2)
    public static let bottomLeft = Corner(rawValue: 1 << 3)

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }
  }

  convenience init(roundedRect rect: NSRect, corners: Corner, cornerRadius: CGFloat) {
    self.init()
    
    if corners.contains(.topLeft) {
      move(to: NSPoint(x: rect.minX + cornerRadius, y: rect.minY))
    } else {
      move(to: NSPoint(x: rect.minX, y: rect.minY))
    }
    
    if corners.contains(.topRight) {
      line(to: NSPoint(x: rect.maxX - cornerRadius, y: rect.minY))
      appendArc(withCenter: NSPoint(x: rect.maxX - cornerRadius, y: rect.minY + cornerRadius),
                radius: cornerRadius,
                startAngle: 270,
                endAngle: 360)
    } else {
      line(to: NSPoint(x: rect.maxX, y: rect.minY))
    }
    
    if corners.contains(.bottomRight) {
      line(to: NSPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
      appendArc(withCenter: NSPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                radius: cornerRadius,
                startAngle: 0,
                endAngle: 90)
    } else {
      line(to: NSPoint(x: rect.maxX, y: rect.maxY))
    }
    
    
    if corners.contains(.bottomLeft) {
      line(to: NSPoint(x: rect.minX + cornerRadius, y: rect.maxY))
      appendArc(withCenter: NSPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                radius: cornerRadius,
                startAngle: 90,
                endAngle: 180)
    } else {
      line(to: NSPoint(x: rect.minX, y: rect.maxY))
    }
    
    if corners.contains(.topLeft) {
      line(to: NSPoint(x: rect.minX, y: rect.minY + cornerRadius))
      appendArc(withCenter: NSPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius),
                radius: cornerRadius,
                startAngle: 180,
                endAngle: 270)
    } else {
      line(to: NSPoint(x: rect.minX, y: rect.minY))
    }
    
    close()
  }
}
