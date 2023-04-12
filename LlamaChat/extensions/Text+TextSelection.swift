//
//  Text+TextSelection.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 12/04/2023.
//

import SwiftUI

struct EnabledTextSelection: ViewModifier {
  func body(content: Content) -> some View {
    content
      .textSelection(.enabled)
  }
}

struct DisabledTextSelection: ViewModifier {
  func body(content: Content) -> some View {
    content
      .textSelection(.disabled)
  }
}

extension View {
  @ViewBuilder func textSelectionEnabled(_ flag: Bool) -> some View {
    if flag {
      modifier(EnabledTextSelection())
    } else {
      modifier(DisabledTextSelection())
    }
  }
}
