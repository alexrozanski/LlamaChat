//
//  AddSourceSheetContentView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

fileprivate struct StepView<Content, PrimaryActions>: View where Content: View, PrimaryActions: View {
  @ObservedObject var viewModel: AddSourceViewModel

  typealias ContentBuilder = () -> Content
  typealias PrimaryActionsBuilder = () -> PrimaryActions

  @ViewBuilder let content: ContentBuilder
  @ViewBuilder let primaryActions: PrimaryActionsBuilder

  var body: some View {
    VStack(spacing: 0) {
      content()
      Rectangle()
        .fill(.separator)
        .frame(height: 1)
      HStack {
        Button("Cancel", action: { viewModel.cancel() })
        Spacer()
        primaryActions()
      }
      .padding(20)
    }
  }
}

public struct AddSourceContentView: View {
  @ObservedObject var viewModel: AddSourceViewModel

  public init(viewModel: AddSourceViewModel) {
    self.viewModel = viewModel
  }

  public var body: some View {
    NavigationStack(path: $viewModel.navigationPath) {
      StepView(viewModel: viewModel, content: {
        SelectSourceTypeView(viewModel: viewModel.selectSourceTypeViewModel)
      }, primaryActions: {})
      .navigationTitle("Add Chat Source")
      .navigationDestination(for: AddSourceStep.self) { step in
        switch step {
        case .configureModel(let configureModelViewModel):
          StepView(viewModel: viewModel, content: {
            ConfigureModelView(viewModel: configureModelViewModel)
              .navigationTitle("Set up \(configureModelViewModel.modelName) model")
          }, primaryActions: {
            ConfigureModelPrimaryActionsView(viewModel: configureModelViewModel)
          })
        case .configureLocal(let configureSourceViewModel):
          StepView(viewModel: viewModel, content: {
            ConfigureLocalModelView(viewModel: configureSourceViewModel)
              .navigationTitle("Set up \(configureSourceViewModel.modelName) model")
          }, primaryActions: {
            PrimaryActionsView(viewModel: configureSourceViewModel.primaryActionsViewModel)
          })
        case .configureRemote(let configureSourceViewModel):
          StepView(viewModel: viewModel, content: {
            ConfigureDownloadableModelView(viewModel: configureSourceViewModel)
              .navigationTitle("Set up \(configureSourceViewModel.modelName) model")
          }, primaryActions: {
            PrimaryActionsView(viewModel: configureSourceViewModel.primaryActionsViewModel)
          })
        case .convertPyTorchSource(let convertSourceViewModel):
          StepView(viewModel: viewModel, content: {
            ConvertSourceView(viewModel: convertSourceViewModel)
              .navigationTitle("Convert PyTorch model files")
          }, primaryActions: {
            ConvertSourcePrimaryActionsView(viewModel: convertSourceViewModel)
          })
        case .configureDetails(let configureDetailsViewModel):
          StepView(viewModel: viewModel, content: {
            ConfigureDetailsView(viewModel: configureDetailsViewModel)
              .navigationTitle("Finishing touches")
          }, primaryActions: {
            PrimaryActionsView(viewModel: configureDetailsViewModel.primaryActionsViewModel)
          })
        }
      }
    }
    .frame(width: 640, height: 450)
  }
}
