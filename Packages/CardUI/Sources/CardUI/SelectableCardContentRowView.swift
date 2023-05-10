//
//  SelectableCardContentRowView.swift
//  
//
//  Created by Alex Rozanski on 10/05/2023.
//

import SwiftUI

public class SelectableCardContentRowViewModel {
  public typealias SelectionHandler = () -> Void

  public enum Action {
    case none
    case `continue`(SelectionHandler)
  }

  public let id: String
  public let label: String
  public let icon: String?
  public let description: String?
  public let selectionHandler: SelectionHandler

  public init(
    id: String,
    label: String,
    icon: String? = nil,
    description: String? = nil,
    selectionHandler: @escaping SelectionHandler
  ) {
    self.id = id
    self.label = label
    self.icon = icon
    self.description = description
    self.selectionHandler = selectionHandler
  }

  func select() {
    selectionHandler()
  }
}


public struct SelectableCardContentRowView: View {
  let viewModel: SelectableCardContentRowViewModel
  let hasBottomBorder: Bool

  @State var hovered = false
  @State var infoPopoverPresented = false

  public init(viewModel: SelectableCardContentRowViewModel, hasBottomBorder: Bool) {
    self.viewModel = viewModel
    self.hasBottomBorder = hasBottomBorder
  }

  public var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .firstTextBaseline) {
        if let icon = viewModel.icon {
          Image(systemName: icon)
        }
        Text(viewModel.label)
          .fontWeight(.medium)
        if let description = viewModel.description {
          Button {
            infoPopoverPresented = true
          } label: {
            Image(systemName: "info.circle.fill")
              .foregroundColor(.gray)
          }
          .buttonStyle(.plain)
          .popover(isPresented: $infoPopoverPresented) {
            Text(description)
              .fixedSize(horizontal: false, vertical: true)
              .frame(width: 200)
              .padding()
          }
        }
        Spacer()
        Image(systemName: "chevron.right")
      }
      .padding(.horizontal, 10)
      .padding(.vertical, 8)
      .background(
        hovered ? CardColors.hoverBackground : .clear
      )
      .onHover { hovered in
        self.hovered = hovered
      }
      .onTapGesture {
        viewModel.select()
      }
      if hasBottomBorder {
        Rectangle()
          .fill(CardColors.border)
          .frame(height: 0.5)
      }
    }
  }
}
