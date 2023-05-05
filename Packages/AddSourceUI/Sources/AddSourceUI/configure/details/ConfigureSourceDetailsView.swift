//
//  ConfigureSourceDetailsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import SwiftUI
import SharedUI

fileprivate struct DisplayNameRowView: View {
  @ObservedObject var viewModel: ConfigureSourceDetailsViewModel

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
  @ObservedObject var viewModel: ConfigureSourceDetailsViewModel

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
      AvatarPickerView(selectedAvatar: selectedAvatarBinding)
    } label: {
      Text("Avatar")
    }
  }
}


struct ConfigureSourceDetailsView: View {
  var viewModel: ConfigureSourceDetailsViewModel

  var body: some View {
    Section {
      DisplayNameRowView(viewModel: viewModel)
      AvatarRowView(viewModel: viewModel)
    }
  }
}
