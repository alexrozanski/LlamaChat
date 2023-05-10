//
//  CardView.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import SwiftUI

public struct CardView<Header, Body>: View where Header: View, Body: View {
  public typealias SelectionHandler = () -> Void
  public typealias HeaderBuilder = () -> Header
  public typealias BodyBuilder = () -> Body

  @State private var hovered = false

  let isSelectable: Bool
  let hasBody: Bool
  let selectionHandler: SelectionHandler?
  let headerBuilder: HeaderBuilder
  let bodyBuilder: BodyBuilder

  public init(
    isSelectable: Bool,
    hasBody: Bool,
    selectionHandler: SelectionHandler?,
    @ViewBuilder header: @escaping HeaderBuilder,
    @ViewBuilder body: @escaping BodyBuilder
  ) {
    self.isSelectable = isSelectable
    self.hasBody = hasBody
    self.selectionHandler = selectionHandler
    self.headerBuilder = header
    self.bodyBuilder = body
  }

  public var body: some View {
    return VStack(spacing: 0) {
      headerBuilder()
        .padding(12)
      if hasBody {
        Rectangle()
          .fill(CardColors.border)
          .frame(height: 0.5)
        bodyBuilder()
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 4)
        .stroke(CardColors.border, lineWidth: 1)
    )
    .background(
      Color(light: .white, dark: .clear)
        .overlay {
          if hovered {
            CardColors.hoverBackground
          }
        }
    )
    .cornerRadius(4)
    .onHover { hovered in
      if isSelectable {
        self.hovered = hovered
      }
    }
    .onTapGesture {
      selectionHandler?()
    }
  }
}

public extension CardView where Body == EmptyView, Header: View {
  init(@ViewBuilder header: @escaping HeaderBuilder) {
    self.init(
      isSelectable: false,
      hasBody: false,
      selectionHandler: nil,
      header: header,
      body: { EmptyView() }
    )
  }

  init(
    isSelectable: Bool,
    selectionHandler: SelectionHandler?,
    @ViewBuilder header: @escaping HeaderBuilder
  ) {
    self.init(
      isSelectable: isSelectable,
      hasBody: false,
      selectionHandler: selectionHandler,
      header: header,
      body: { EmptyView() }
    )
  }
}
