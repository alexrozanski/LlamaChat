//
//  BorderlessTextField.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import SwiftUI

struct BorderlessTextField: NSViewRepresentable {
  var placeholder: String
  @Binding var text: String

  init(_ placeholder: String, text: Binding<String>) {
    self.placeholder = placeholder
    _text = text
  }

  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: BorderlessTextField

    init(_ parent: BorderlessTextField) {
      self.parent = parent
    }

    func controlTextDidChange(_ obj: Notification) {
      if let textField = obj.object as? NSTextField {
        parent.text = textField.stringValue
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField()
    textField.delegate = context.coordinator
    textField.focusRingType = .none
    textField.isBordered = false
    textField.font = NSFont.systemFont(ofSize: 13)
    textField.placeholderString = placeholder
    return textField
  }

  func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.stringValue = text
  }
}
