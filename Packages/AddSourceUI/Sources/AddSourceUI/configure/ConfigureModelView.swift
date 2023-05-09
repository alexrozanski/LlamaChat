//
//  ConfigureSourceView.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import SwiftUI

fileprivate struct ModelSourceView: View {
  let viewModel: ModelSourceViewModel
  @ObservedObject var configureModelViewModel: ConfigureModelViewModel

  var body: some View {
    CardView(viewModel: CardViewModel(
      contentViewModel: (),
      isSelectable: configureModelViewModel.isSelectingSource,
      hasBody: configureModelViewModel.isConfiguringSource,
      selectionHandler: {
        configureModelViewModel.selectedSource = viewModel.source
      })
    ) { _ in
      HStack(alignment: .firstTextBaseline) {
        Image(systemName: viewModel.icon)
        VStack(alignment: .leading, spacing: 4) {
          HStack(alignment: .firstTextBaseline) {
            Text(viewModel.title)
              .fontWeight(.semibold)
            if viewModel.source == .remote {
              PillView(label: "Recommended")
            }
          }
          if let description = viewModel.description {
            Text(description)
              .font(.system(size: 11))
          }
        }
        Spacer()
        if configureModelViewModel.isSelectingSource {
          if configureModelViewModel.selectedSource == viewModel.source {
            Image(systemName: "checkmark.circle.fill")
          } else {
            Image(systemName: "circle")
          }
        }
      }
    } body: {
      EmptyView()
    }
  }
}

struct ConfigureModelView: View {
  @ObservedObject var viewModel: ConfigureModelViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("How do you want to add the model files needed for this source?")
        .padding(.horizontal, 12)
      ForEach(viewModel.sourceViewModels, id: \.id) { sourceViewModel in
        ModelSourceView(
          viewModel: sourceViewModel,
          configureModelViewModel: viewModel
        )
      }
      Spacer()
    }
    .padding()
  }
}
