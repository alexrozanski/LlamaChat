//
//  ConfigureLlamaSourceView.swift
//  Camel
//
//  Created by Alex Rozanski on 30/03/2023.
//

import SwiftUI

fileprivate struct ModelPathTextField: View {
  @ObservedObject var viewModel: ConfigureLlamaSourceViewModel

  var body: some View {
    VStack(alignment: .trailing) {
      TextField("/path/to/model/file", text: $viewModel.modelPath)
      if viewModel.modelPathState == .invalid {
        HStack(spacing: 4) {
          Image(systemName: "exclamationmark.triangle")
            .foregroundColor(.red)
          Text("Model file not found at path")
            .foregroundColor(.red)
            .font(.footnote)
        }
      }
    }
  }
}

struct ConfigureLlamaSourceView: View {
  @ObservedObject var viewModel: ConfigureLlamaSourceViewModel

  @ViewBuilder var pathSelector: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .top) {
        Text("Model Path")
        ModelPathTextField(viewModel: viewModel)
        Button(action: {
          let panel = NSOpenPanel()
          panel.allowsMultipleSelection = false
          panel.canChooseDirectories = false
          if panel.runModal() == .OK {
            viewModel.modelPath = panel.url?.path ?? ""
          }
        }, label: {
          Image(systemName: "ellipsis")
        })
      }
      Text("Select the quantized LLaMa model path. This should be called something like 'ggml-model-q4_0.bin'")
        .font(.footnote)
        .padding(.top, 8)
    }
    .padding(12)
    .mask(RoundedRectangle(cornerRadius: 6))
    .background(Color(cgColor: NSColor.systemGray.withAlphaComponent(0.05).cgColor))
    .overlay(
      RoundedRectangle(cornerRadius: 6)
        .stroke(Color(cgColor: NSColor.separatorColor.cgColor), lineWidth: 0.5)
    )
  }

  @ViewBuilder var navigation: some View {
    HStack {
      Button("Back") {
        viewModel.goBack()
      }
      Spacer()
      Button("Add") {
        viewModel.addSource()
      }
      .keyboardShortcut(.return)
      .disabled(!viewModel.modelPathState.isValid)
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      VStack(alignment: .leading, spacing: 12) {
        Text("Set up LLaMa")
          .font(.headline)
      }
      .padding(.horizontal, 12)
      pathSelector
      Spacer()
      navigation
    }
  }
}
