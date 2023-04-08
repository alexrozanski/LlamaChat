//
//  NSScrollView+Bottom.swift
//  CamelChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import AppKit

extension NSScrollView {
  func isScrolledToBottom() -> Bool {
    return contentView.bounds.origin.y == 0
  }
}
