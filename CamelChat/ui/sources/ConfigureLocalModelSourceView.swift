//
//  ConfigureLocalModelSourceView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

fileprivate struct ModelPathTextField: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

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

struct ConfigureLocalModelSourceView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

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

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Set up LLaMa")
        .font(.headline)
        .padding(.horizontal, 12)
      pathSelector
    }
  }
}
