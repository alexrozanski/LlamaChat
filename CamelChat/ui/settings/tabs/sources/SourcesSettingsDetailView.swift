//
//  SourcesSettingsDetailView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct NameRowView: View {
  var viewModel: SourcesSettingsDetailViewModel

  @State var name: String

  init(viewModel: SourcesSettingsDetailViewModel) {
    self.viewModel = viewModel
    _name = State(wrappedValue: viewModel.name)
  }

  var body: some View {
    LabeledContent("Name") {
      DidEndEditingTextField(text: $name, didEndEditing: { newName in
        viewModel.updateName(newName)
      })
    }
    .onChange(of: viewModel.name) { name = $0 }
  }
}

struct SourcesSettingsDetailView: View {
  var viewModel: SourcesSettingsDetailViewModel

  var body: some View {
    let modelPathBinding = Binding(
      get: { viewModel.modelPath },
      set: { _ in }
    )
    Form {
      NameRowView(viewModel: viewModel)
      TextField("Model path", text: modelPathBinding)
        .textFieldStyle(SquareBorderTextFieldStyle())
        .disabled(true)
    }
    .formStyle(GroupedFormStyle())
  }
}
