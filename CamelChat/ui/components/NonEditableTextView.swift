//
//  NonEditableTextView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import AppKit
import SwiftUI

struct NonEditableTextView: NSViewRepresentable {
  enum Text {
    case unformatted(String, NSFont?)
    case richText(NSAttributedString)
  }

  let text: Text

  func makeNSView(context: Context) -> NSScrollView {
    let scrollView = NSTextView.scrollableTextView()
    guard let textView = scrollView.documentView as? NSTextView else {
      return scrollView
    }
    scrollView.documentView = textView

    setText(text, in: textView)
    textView.isEditable = false
    textView.textContainerInset = NSSize(width: 8, height: 8)

    return scrollView
  }

  func updateNSView(_ nsView: NSScrollView, context: Context) {
    if let textView = nsView.documentView as? NSTextView {
      setText(text, in: textView)
    }
  }
}

private func setText(_ text: NonEditableTextView.Text, in textView: NSTextView) {
  switch text {
  case .unformatted(let string, let font):
    textView.string = string
    textView.font = font
  case .richText(let attributedString):
    textView.textStorage?.setAttributedString(attributedString)
  }
}
