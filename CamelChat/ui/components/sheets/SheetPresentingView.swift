//
//  SheetPresentingView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

protocol SheetViewModel {}

struct SheetPresentingView<SheetView>: View where SheetView: View {
  typealias SheetViewBuilder = (SheetViewModel) -> SheetView

  var viewModel: SheetViewModel?
  @State var sheetPresented = true

  @ViewBuilder var sheetViewBuilder: SheetViewBuilder

  var body: some View {
    if let viewModel {
      Color.clear
        .sheet(isPresented: $sheetPresented) {
          sheetViewBuilder(viewModel)
        }
    }
  }
}
