//
//  CardContentRowView.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import SwiftUI

public class CardContentRowViewModel {
  public typealias SelectionHandler = () -> Void

  public enum Action {
    case none
    case `continue`(SelectionHandler)
  }

  public let id: String
  public let label: String
  public let icon: String?
  public let description: String?
  public let action: Action

  var hasChevron: Bool {
    switch action {
    case .none:
      return false
    case .continue:
      return true
    }
  }

  var isSelectable: Bool {
    switch action {
    case .none:
      return false
    case .continue:
      return true
    }
  }

  public init(
    id: String,
    label: String,
    icon: String? = nil,
    description: String? = nil,
    action: Action
  ) {
    self.id = id
    self.label = label
    self.icon = icon
    self.description = description
    self.action = action
  }

  func select() {
    switch action {
    case .none:
      break
    case .continue(let selectionHandler):
      selectionHandler()
    }
  }
}


public struct CardContentRowView<Content>: View where Content: View {
  public typealias ContentBuilder = () -> Content

  let label: String?
  let hasBottomBorder: Bool
  let contentBuilder: ContentBuilder

  public init(label: String, hasBottomBorder: Bool, content: @escaping ContentBuilder) {
    self.label = label
    self.hasBottomBorder = hasBottomBorder
    self.contentBuilder = content
  }

  public init(hasBottomBorder: Bool, content: @escaping ContentBuilder) {
    self.label = nil
    self.hasBottomBorder = hasBottomBorder
    self.contentBuilder = content
  }

  public var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .firstTextBaseline) {
        HStack(alignment: .firstTextBaseline) {
          if let label {
            Text(label)
              .fontWeight(.medium)
            Spacer()
          }
          contentBuilder()
        }
        .padding(.leading, 28)
        if label == nil {
          Spacer()
        }
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      if hasBottomBorder {
        Rectangle()
          .fill(CardColors.border)
          .frame(height: 0.5)
      }
    }
  }
}
