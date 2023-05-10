//
//  ConfigureLocalPyTorchModelSettingsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI
import CardUI
import SharedUI

struct ConfigureLocalPyTorchModelSettingsView: View {
  @ObservedObject var viewModel: ConfigureLocalPyTorchModelSettingsViewModel  

  var body: some View {
    switch viewModel.conversionState {
    case .unknown:
      EmptyView()
    case .loading:
      LabeledContent { Text("") } label: { Text("") }
      .overlay(
        DebouncedView(isVisible: true, delay: 0.2) {
          ProgressView()
            .progressViewStyle(.circular)
            .controlSize(.small)
        }
      )
    case .canConvert(let canConvert):
      if canConvert {
        VariantPickerView(
          viewModel: viewModel.variantPickerViewModel,
          unknownModelVariantAppearance: .disabled
        )
      } else {
        LabeledContent { Text("") } label: {
          Text("Cannot automatically convert PyTorch model files. Please convert manually using the conversion steps outlined in the [llama.cpp repository](https://github.com/ggerganov/llama.cpp) and import them as a GGML model file.")
            .lineSpacing(2)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
    }
    if viewModel.showPathSelector {
      VStack(alignment: .leading, spacing: 0) {
        PathSelectorView(viewModel: viewModel.pathSelectorViewModel)
        if let files = viewModel.files {
          CardContentRowView(hasBottomBorder: true) {
            VStack(alignment: .leading, spacing: 4) {
              ForEach(files, id: \.url) { file in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                  Image(systemName: file.found ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(file.found ? .green : .red)
                  Text(file.url.path)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.head)
                }
              }
            }
          }
        }
      }
    }
  }
}
