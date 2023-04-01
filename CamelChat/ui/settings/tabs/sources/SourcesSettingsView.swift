//
//  SourcesSettingsView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SourcesSettingsView: View {
  @ObservedObject var viewModel: SourcesSettingsViewModel

  @ViewBuilder var detailView: some View {
    if let detailViewModel = viewModel.makeSelectedSourceDetailViewModel() {
      SourcesSettingsDetailView(viewModel: detailViewModel)
    } else {
      Text("Select a source to configure its settings")
    }
  }

  var body: some View {
    HStack(spacing: 0) {
      SourcesSettingsListView(viewModel: viewModel)
        .overlay {
          SheetPresentingView(viewModel: viewModel.activeSheetViewModel) { viewModel in
            if let viewModel = viewModel as? ConfirmDeleteSourceSheetViewModel {
              ConfirmDeleteSourceSheetContentView(viewModel: viewModel)
            } else if let viewModel = viewModel as? AddSourceSheetViewModel {
              AddSourceSheetContentView(viewModel: viewModel)
            }
          }
        }
        .padding([.top, .leading, .bottom])
        .frame(width: 200)
      detailView
        .frame(maxWidth: .infinity)
    }
  }
}
