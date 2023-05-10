//
//  LabeledCardView.swift
//  
//
//  Created by Alex Rozanski on 10/05/2023.
//

import SwiftUI

public struct LabeledCardView<Content>: View where Content: View {
  public let label: String
  public let icon: String?
  public let isSelectable: Bool
  public let selectionHandler: CardView.SelectionHandler?
  public let contentBuilder: () -> Content

  public init(
    _ label: String,
    icon: String? = nil,
    isSelectable: Bool,
    selectionHandler: CardView.SelectionHandler?,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.label = label
    self.icon = icon
    self.isSelectable = isSelectable
    self.selectionHandler = selectionHandler
    contentBuilder = content
  }

  public init(_ label: String, icon: String? = nil, @ViewBuilder content: @escaping () -> Content) {
    self.init(label, icon: icon, isSelectable: false, selectionHandler: nil, content: content)
  }

  public var body: some View {
    CardView(isSelectable: isSelectable, selectionHandler: selectionHandler) {
      HStack {
        if let icon {
          Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
        }
        Text(label)
          .fontWeight(.medium)
        Spacer()
        contentBuilder()
      }
    }
  }
}
