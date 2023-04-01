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
  }
}

struct SourcesSettingsDetailView: View {
  var viewModel: SourcesSettingsDetailViewModel

  var body: some View {
    Form {
      NameRowView(viewModel: viewModel)
      LabeledContent("Model type", value: viewModel.type)
      LabeledContent("Model path") {
        HStack {
          Text(viewModel.modelPath)
            .font(.system(size: 11))
            .lineLimit(1)
            .help(viewModel.modelPath)
          Menu(content: {
            Button("Show in Finder...") {
              viewModel.showModelInFinder()
            }
          }, label: {
            Image(systemName: "ellipsis.circle")
          })
          .buttonStyle(.borderless)
          .menuIndicator(.hidden)
          Spacer()
        }
      }
    }
    .formStyle(GroupedFormStyle())
  }
}
