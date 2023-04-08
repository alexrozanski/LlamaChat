//
//  NonEditableTextView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import AppKit
import SwiftUI

struct NonEditableTextView: NSViewRepresentable {
  let text: String
  let font: NSFont

  func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSTextView.scrollableTextView()
    guard let textView = scrollView.documentView as? NSTextView else {
      return scrollView
    }
    scrollView.documentView = textView
    textView.string = text
    textView.isEditable = false
    textView.textContainerInset = NSSize(width: 8, height: 8)
    textView.font = font

    return scrollView
  }

  func updateNSView(_ nsView: NSScrollView, context: Context) {
    if let textView = nsView.documentView as? NSTextView {
      textView.string = text
      textView.font = font
    }
  }
}
