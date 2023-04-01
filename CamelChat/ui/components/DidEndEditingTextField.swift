//
//  DidEndEditingTextField.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct DidEndEditingTextField: NSViewRepresentable {
  @Binding var text: String
  var didEndEditing: (String) -> Void

  class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: DidEndEditingTextField

    init(_ parent: DidEndEditingTextField) {
      self.parent = parent
    }

    func controlTextDidChange(_ obj: Notification) {
      if let textField = obj.object as? NSTextField {
        parent.text = textField.stringValue
      }
    }

    func controlTextDidEndEditing(_ obj: Notification) {
      if let textField = obj.object as? NSTextField {
        parent.didEndEditing(textField.stringValue)
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField()
    textField.delegate = context.coordinator
    return textField
  }

  func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.stringValue = text
  }
}
