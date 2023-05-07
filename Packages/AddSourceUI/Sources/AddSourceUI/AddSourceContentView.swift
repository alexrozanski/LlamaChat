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
      Spacer()
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
          .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
      }, primaryActions: {})
      .navigationTitle("Add Chat Source")
      .navigationDestination(for: AddSourceStep.self) { step in
        switch step {
        case .configureLocal(let configureSourceViewModel):
          StepView(viewModel: viewModel, content: {
            ConfigureLocalModelSourceView(viewModel: configureSourceViewModel)
              .navigationTitle("Set up \(configureSourceViewModel.chatSourceType.readableName) model")
          }, primaryActions: {
            ConfigureSourcePrimaryActionsView(viewModel: configureSourceViewModel.primaryActionsViewModel)
          })
        case .configureRemote(let configureSourceViewModel):
          StepView(viewModel: viewModel, content: {
            ConfigureDownloadableModelSourceView(viewModel: configureSourceViewModel)
              .navigationTitle("Set up \(configureSourceViewModel.chatSourceType.readableName) model")
          }, primaryActions: {
            ConfigureSourcePrimaryActionsView(viewModel: configureSourceViewModel.primaryActionsViewModel)
          })
        case .convertPyTorchSource(let convertSourceViewModel):
          StepView(viewModel: viewModel, content: {
            ConvertSourceView(viewModel: convertSourceViewModel)
              .navigationTitle("Convert PyTorch model files")
          }, primaryActions: {
            ConvertSourcePrimaryActionsView(viewModel: convertSourceViewModel)
          })
        }
      }
    }
    .frame(width: 640, height: 450)
  }
}
