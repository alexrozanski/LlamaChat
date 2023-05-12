//
//  ConfigureLocalGgmlModelSettingsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct ConfigureLocalGgmlModelSettingsView: View {
  @ObservedObject var viewModel: ConfigureLocalGgmlModelSettingsViewModel

  var body: some View {
    PathSelectorView(viewModel: viewModel.pathSelectorViewModel)
    if viewModel.showVariantPicker {
      VariantPickerView(
        viewModel: viewModel.variantPickerViewModel,
        enabled: viewModel.modelState.isValid,
        unknownModelVariantAppearance: .regular
      )
    }
  }
}
