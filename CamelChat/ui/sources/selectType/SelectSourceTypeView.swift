//
//  SelectSourceTypeView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

struct SelectSourceTypeView: View {
  @ObservedObject var viewModel: SelectSourceTypeViewModel

  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: 4) {
        Text("To start interacting with one of the models, choose a chat source based on your available model data.")
          .lineLimit(nil)
          .fixedSize(horizontal: false, vertical: true)
      }
      .padding()
      SourceTypeSelectionView(viewModel: viewModel)
      Spacer()
    }
    .padding(24)
  }
}
