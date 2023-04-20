//
//  SourceSettingsPropertiesView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 19/04/2023.
//

import SwiftUI

fileprivate struct NameRowView: View {
  @ObservedObject var viewModel: SourceSettingsPropertiesViewModel

  @State var name: String

  init(viewModel: SourceSettingsPropertiesViewModel) {
    self.viewModel = viewModel
    _name = State(wrappedValue: viewModel.name)
  }

  var body: some View {
    LabeledContent("Display Name") {
      DidEndEditingTextField(text: $name, didEndEditing: { newName in
        viewModel.updateName(newName)
      })
    }
    .onChange(of: viewModel.name) { newName in
      name = newName
    }
  }
}

fileprivate struct AvatarRowView: View {
  @ObservedObject var viewModel: SourceSettingsPropertiesViewModel

  @State var name: String

  init(viewModel: SourceSettingsPropertiesViewModel) {
    self.viewModel = viewModel
    _name = State(wrappedValue: viewModel.name)
  }

  var body: some View {
    let selectedAvatarBinding = Binding(
      get: { viewModel.avatarImageName },
      set: { viewModel.avatarImageName = $0 }
    )
    LabeledContent("Avatar") {
      AvatarPickerView(selectedAvatar: selectedAvatarBinding)
    }
  }
}


struct SourceSettingsPropertiesView: View {
  var viewModel: SourceSettingsPropertiesViewModel

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
    .formStyle(.grouped)
  }
}
