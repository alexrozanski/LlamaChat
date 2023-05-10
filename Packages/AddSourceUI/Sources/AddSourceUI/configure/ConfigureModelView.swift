//
//  ConfigureSourceView.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import SwiftUI
import CardUI

fileprivate struct ModelSourceView: View {
  let viewModel: ModelSourceViewModel
  @ObservedObject var configureModelViewModel: ConfigureModelViewModel

  @ViewBuilder var configureView: some View {
    switch viewModel.source {
    case .local:
      switch configureModelViewModel.state {
      case .configuringLocalModel(let localModelViewModel):
        ConfigureLocalModelView(viewModel: localModelViewModel)
      case .selectingSource, .configuringRemoteModel:
        EmptyView()
      }
    case .remote:
      switch configureModelViewModel.state {
      case .configuringRemoteModel(let downloadableModelViewModel):
        ConfigureDownloadableModelView(viewModel: downloadableModelViewModel)
      case .selectingSource, .configuringLocalModel:
        EmptyView()
      }
    }
  }

  var body: some View {
    CardView(
      isSelectable: configureModelViewModel.isSelectingSource,
      hasBody: configureModelViewModel.isConfiguringSource,
      selectionHandler: {
        configureModelViewModel.selectedSource = viewModel.source
      }
    ) {
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
              .font(.system(size: 12))
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
      configureView
    }
  }
}

struct ConfigureModelView: View {
  @ObservedObject var viewModel: ConfigureModelViewModel

  var body: some View {
    ScrollView {
      CardStack {
        if viewModel.isSourceSelectable {
          CardStackText("How do you want to add the model files needed for this source?")
        }
        ForEach(viewModel.sourceViewModels, id: \.id) { sourceViewModel in
          ModelSourceView(
            viewModel: sourceViewModel,
            configureModelViewModel: viewModel
          )
        }
      }
      .padding(20)
    }
  }
}

struct ConfigureModelPrimaryActionsView: View {
  @ObservedObject var viewModel: ConfigureModelViewModel

  var body: some View {
    switch viewModel.state {
    case .selectingSource:
      PrimaryActionsView(viewModel: viewModel.primaryActionsViewModel)
    case .configuringLocalModel(let localViewModel):
      PrimaryActionsView(viewModel: localViewModel.primaryActionsViewModel)
    case .configuringRemoteModel(let remoteViewModel):
      PrimaryActionsView(viewModel: remoteViewModel.primaryActionsViewModel)
    }
  }
}
