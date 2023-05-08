//
//  DidEndEditingTextField.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

public struct DidEndEditingTextField: NSViewRepresentable {
  var text: Binding<String>
  let didEndEditing: (String) -> Void

  public init(text: Binding<String>, didEndEditing: @escaping (String) -> Void) {
    self.text = text
    self.didEndEditing = didEndEditing
  }

  public class Coordinator: NSObject, NSTextFieldDelegate {
    var parent: DidEndEditingTextField

    init(_ parent: DidEndEditingTextField) {
      self.parent = parent
    }

    public func controlTextDidChange(_ obj: Notification) {
      if let textField = obj.object as? NSTextField {
        parent.text.wrappedValue = textField.stringValue
      }
    }

    public func controlTextDidEndEditing(_ obj: Notification) {
      if let textField = obj.object as? NSTextField {
        parent.didEndEditing(textField.stringValue)
      }
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  public func makeNSView(context: Context) -> NSTextField {
    let textField = NSTextField()
    textField.delegate = context.coordinator
    return textField
  }

  public func updateNSView(_ nsView: NSTextField, context: Context) {
    nsView.stringValue = text.wrappedValue
  }
}
