//
//  SourcesSettingsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI
import AddSourceUI
import ModelCompatibility
import SharedUI

struct SourcesSettingsView<ParametersContent>: View where ParametersContent: View {
  @ObservedObject var viewModel: SourcesSettingsViewModel
  let parametersContent: (ModelParametersViewModel?) -> ParametersContent

  @ViewBuilder var detailView: some View {
    if let detailViewModel = viewModel.detailViewModel {
      SourcesSettingsDetailView(viewModel: detailViewModel, parametersContent: parametersContent)
        .id(detailViewModel.id)
    } else {
      Text("Select a source to configure its settings")
    }
  }

  var body: some View {
    HStack(spacing: 0) {
      SourcesSettingsListView(viewModel: viewModel)
        .padding([.top, .leading, .bottom])
        .frame(width: 200)
      detailView
        .padding([.top])
        .frame(maxWidth: .infinity)
    }
    .sheet(isPresented: $viewModel.sheetPresented) {
      if let viewModel = viewModel.sheetViewModel as? ConfirmDeleteSourceSheetViewModel {
        ConfirmDeleteSourceSheetContentView(viewModel: viewModel)
      } else if let viewModel = viewModel.sheetViewModel as? AddSourceViewModel {
        AddSourceContentView(viewModel: viewModel)
          .interactiveDismissDisabled()
      }
    }
  }
}
