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
    VStack(alignment: .leading) {
      PathSelectorView(viewModel: viewModel.pathSelectorViewModel)
      Text("Select the quantized \(viewModel.modelName) model path. This should be called something like '\(viewModel.exampleModelPath)'")
        .font(.footnote)
        .padding(.top, 8)
    }
    VariantPickerView(
      viewModel: viewModel.variantPickerViewModel,
      enabled: viewModel.modelState.isValid,
      unknownModelVariantAppearance: .regular
    )
  }
}
