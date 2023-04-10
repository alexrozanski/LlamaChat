//
//  SourcesSettingsDetailView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

fileprivate struct NameRowView: View {
  var viewModel: SourcesSettingsDetailViewModel

  @State var name: String

  init(viewModel: SourcesSettingsDetailViewModel) {
    self.viewModel = viewModel
    _name = State(wrappedValue: viewModel.name)
  }

  var body: some View {
    LabeledContent("Display Name") {
      DidEndEditingTextField(text: $name, didEndEditing: { newName in
        viewModel.updateName(newName)
      })
    }
  }
}

fileprivate struct AvatarRowView: View {
  var viewModel: SourcesSettingsDetailViewModel

  @State var name: String

  init(viewModel: SourcesSettingsDetailViewModel) {
    self.viewModel = viewModel
    _name = State(wrappedValue: viewModel.name)
  }

  var body: some View {
    LabeledContent("Avatar") {
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
      Section {
        NameRowView(viewModel: viewModel)
        AvatarRowView(viewModel: viewModel)
      }
      Section("Model") {
        LabeledContent("Model Type", value: viewModel.type)
        LabeledContent("Model Path") {
          HStack {
            Text(viewModel.modelPath)
              .font(.system(size: 11))
              .lineLimit(1)
              .truncationMode(.middle)
              .frame(maxWidth: 200)
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
          }
        }
        LabeledContent("Model Size") {
          Text(viewModel.modelSize)
        }
      }
    }
    .formStyle(GroupedFormStyle())
  }
}
