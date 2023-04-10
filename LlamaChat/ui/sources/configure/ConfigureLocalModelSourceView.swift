//
//  ConfigureLocalModelSourceView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

fileprivate struct DisplayNameRowView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

  @FocusState var isNameFocused: Bool

  var body: some View {
    let nameBinding = Binding(
      get: { viewModel.name },
      set: { viewModel.name = $0 }
    )
    HStack {
      TextField("Display Name", text: nameBinding)
        .textFieldStyle(.squareBorder)
        .focused($isNameFocused)
      Button(action: {
        viewModel.generateName()
      }, label: { Image(systemName: "hands.sparkles.fill") })
    }
    .onAppear {
      isNameFocused = true
    }
  }
}

fileprivate struct AvatarRowView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

  @State var pickerPresented = false

  @ViewBuilder var picker: some View {
    if let avatarImageName = viewModel.avatarImageName {
      Image(avatarImageName)
        .resizable()

    } else {
      Circle()
        .fill(.gray.opacity(0.2))
        .overlay(
          Image(systemName: "plus")
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .foregroundColor(.gray)
        )
    }
  }

  var body: some View {
    LabeledContent {
      let selectedAvatarBinding = Binding(
        get: { viewModel.avatarImageName },
        set: { viewModel.avatarImageName = $0 }
      )
      picker
        .frame(width: 48, height: 48)
        .onTapGesture {
          pickerPresented = true
        }
        .popover(isPresented: $pickerPresented, arrowEdge: .bottom) {
          AvatarPickerView(selectedAvatar: selectedAvatarBinding)
        }
    } label: {
      Text("Avatar")
    }
  }
}

struct ConfigureLocalModelSourceView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

  @State var selectedModelType: String = ""

  var body: some View {
    Form {
      Section {
        DisplayNameRowView(viewModel: viewModel)
        AvatarRowView(viewModel: viewModel)
      }
      ConfigureLocalModelSelectFormatView(viewModel: viewModel)

      if let settingsViewModel = viewModel.settingsViewModel {
        Section {
          if let settingsViewModel = settingsViewModel as? ConfigureLocalGgmlModelSettingsViewModel {
            ConfigureLocalGgmlModelSettingsView(viewModel: settingsViewModel)
          } else if let settingsViewModel = settingsViewModel as? ConfigureLocalPyTorchModelSettingsViewModel {
            ConfigureLocalPyTorchModelSettingsView(viewModel: settingsViewModel)
          }
        }
      }
    }
    .formStyle(GroupedFormStyle())
  }
}
