//
//  CardRowStack.swift
//  
//
//  Created by Alex Rozanski on 10/05/2023.
//

import SwiftUI

public struct CardRowStack<Content>: View where Content: View {
  let content: () -> Content
  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    VStack(spacing: 0) {
      content()
    }
  }
}
