//
//  CardView.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import SwiftUI

public struct CardView<ContentViewModel, Header, Body>: View where Header: View, Body: View {
  public typealias HeaderBuilder = (ContentViewModel) -> Header
  public typealias BodyBuilder = (ContentViewModel) -> Body

  @State private var hovered = false

  @ObservedObject public var viewModel: CardViewModel<ContentViewModel>
  let headerBuilder: HeaderBuilder
  let bodyBuilder: BodyBuilder

  public init(viewModel: CardViewModel<ContentViewModel>, header: @escaping HeaderBuilder, body: @escaping BodyBuilder) {
    self.viewModel = viewModel
    self.headerBuilder = header
    self.bodyBuilder = body
  }

  public var body: some View {
    return VStack(spacing: 0) {
      headerBuilder(viewModel.contentViewModel)
        .padding(12)
      if viewModel.hasBody {
        Rectangle()
          .fill(CardColors.border)
          .frame(height: 0.5)
        bodyBuilder(viewModel.contentViewModel)
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
      if viewModel.isSelectable {
        self.hovered = hovered
      }
    }
    .onTapGesture {
      viewModel.select()
    }
  }
}
