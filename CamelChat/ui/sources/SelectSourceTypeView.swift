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
        Text("Add Chat Source")
          .font(.headline)
        Text("To start interacting with one of the models, choose a chat source based on your available model data.")
      }
      .padding()
      SourceTypeSelectionView(viewModel: viewModel)
      Spacer()
    }
    .padding(24)
  }
}
