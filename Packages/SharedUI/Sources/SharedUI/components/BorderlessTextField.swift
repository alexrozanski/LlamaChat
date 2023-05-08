//
//  BorderlessTextField.swift
//  Camel
//
//  Created by Alex Rozanski on 31/03/2023.
//

import SwiftUI

public struct BorderlessTextField: NSViewRepresentable {
  var placeholder: String
  @Binding var text: String

  public init(_ placeholder: String, text: Binding<String>) {
    self.placeholder = placeholder
    _text = text
  }

  public class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: BorderlessTextField

    init(_ parent: BorderlessTextField) {
      self.parent = parent
    }

    public func controlTextDidChange(_ obj: Notification) {
      if let textField = obj.object as? NSTextField {
        parent.text = textField.stringValue
      }
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField()
    textField.delegate = context.coordinator
    textField.focusRingType = .none
    textField.isBordered = false
    textField.font = NSFont.systemFont(ofSize: 13)
    textField.placeholderString = placeholder
    return textField
  }

  public func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.stringValue = text
    nsView.placeholderString = placeholder
  }
}
