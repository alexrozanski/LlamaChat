//
//  ConfigureLocalPyTorchModelSettingsView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct ConfigureLocalPyTorchModelSettingsView: View {
  @ObservedObject var viewModel: ConfigureLocalPyTorchModelSettingsViewModel

  var body: some View {
    ConfigureLocalModelSizePickerView(
      viewModel: viewModel.modelSizePickerViewModel,
      unknownModelSizeAppearance: .disabled
    )
    if viewModel.showPathSelector {
      ConfigureLocalModelPathSelectorView(
        viewModel: viewModel.pathSelectorViewModel,
        useMultiplePathSelection: viewModel.requiredNumberOfModelFiles != 1,
        modelState: viewModel.modelState
      )
    }
  }
}
