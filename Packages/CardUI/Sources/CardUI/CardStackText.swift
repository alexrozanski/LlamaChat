//
//  CardStackText.swift
//  
//
//  Created by Alex Rozanski on 10/05/2023.
//

import SwiftUI

public struct CardStackText: View {
  let text: String
  public init(_ text: String) {
    self.text = text
  }

  public var body: some View {
    Text(text)
      .padding(.horizontal, 12)
  }
}
