//
//  AddSourceSheetContentView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct AddSourceContentView: View {
  @ObservedObject var viewModel: AddSourceViewModel

  var body: some View {
    NavigationStack(path: $viewModel.navigationPath) {
      SelectSourceTypeView(viewModel: viewModel.selectSourceTypeViewModel)
        .navigationTitle("Add Chat Source")
        .navigationDestination(for: AddSourceStep.self) { step in
          switch step {
          case .configureSource:
            if let configureSourceViewModel = viewModel.configureSourceViewModel {
              makeConfigureSourceView(from: configureSourceViewModel)
                .navigationTitle("Set up \(configureSourceViewModel.chatSourceType.readableName) model")
            }
          case .convertPyTorchSource:
            if let convertSourceViewModel = viewModel.convertSourceViewModel {
              ConvertSourceView(viewModel: convertSourceViewModel)
                .navigationTitle("Convert PyTorch model files")
            }
          }
        }
    }
    .frame(width: 620, height: 430)
  }
}
