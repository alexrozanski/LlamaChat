//
//  CardStack.swift
//  
//
//  Created by Alex Rozanski on 10/05/2023.
//

import SwiftUI

public struct CardStack<Content>: View where Content: View {
  let content: () -> Content
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      content()
      Spacer()
    }
  }
}
