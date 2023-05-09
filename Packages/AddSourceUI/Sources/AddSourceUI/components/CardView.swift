//
//  CardView.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import SwiftUI

class CardViewModel<ContentViewModel>: ObservableObject {
  typealias SelectionHandler = () -> Void

  let contentViewModel: ContentViewModel
  private let selectionHandler: SelectionHandler

  @Published var isSelectable: Bool
  @Published var hasBody: Bool

  init(
    contentViewModel: ContentViewModel,
    isSelectable: Bool,
    hasBody: Bool,
    selectionHandler: @escaping SelectionHandler
  ) {
    self.contentViewModel = contentViewModel
    self.isSelectable = isSelectable
    self.hasBody = hasBody
    self.selectionHandler = selectionHandler
  }

  func select() {
    if isSelectable {
      selectionHandler()
    }
  }
}

struct CardViewColors {
  static let border = Color(light: Color(hex: "#DEDEDE"), dark: Color(hex: "#FFFFFF", opacity: 0.2))
  static let hoverBackground = Color(light: .black.opacity(0.02), dark: .black.opacity(0.2))
}

struct CardView<ContentViewModel, Header, Body>: View where Header: View, Body: View {
  typealias HeaderBuilder = (ContentViewModel) -> Header
  typealias BodyBuilder = (ContentViewModel) -> Body

  @State private var hovered = false

  @ObservedObject var viewModel: CardViewModel<ContentViewModel>
  let headerBuilder: HeaderBuilder
  let bodyBuilder: BodyBuilder

  init(viewModel: CardViewModel<ContentViewModel>, header: @escaping HeaderBuilder, body: @escaping BodyBuilder) {
    self.viewModel = viewModel
    self.headerBuilder = header
    self.bodyBuilder = body
  }

  var body: some View {
    return VStack(spacing: 0) {
      headerBuilder(viewModel.contentViewModel)
        .padding(12)
      if viewModel.hasBody {
        Rectangle()
          .fill(CardViewColors.border)
          .frame(height: 0.5)
        bodyBuilder(viewModel.contentViewModel)
      }
    }
    .background(
      RoundedRectangle(cornerRadius: 4)
        .stroke(CardViewColors.border, lineWidth: 1)
    )
    .background(
      Color(light: .white, dark: .clear)
        .overlay {
          if hovered {
            CardViewColors.hoverBackground
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
