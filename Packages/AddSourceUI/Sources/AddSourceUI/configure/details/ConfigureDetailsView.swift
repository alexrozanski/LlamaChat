//
//  ConfigureDetailsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import SwiftUI
import CardUI
import SharedUI

fileprivate struct DisplayNameRowView: View {
  @ObservedObject var viewModel: ConfigureDetailsViewModel

  @FocusState var isNameFocused: Bool

  var body: some View {
    let nameBinding = Binding(
      get: { viewModel.name },
      set: { viewModel.name = $0 }
    )
    LabeledCardView("Display Name") {
      HStack {
        TextField("", text: nameBinding)
          .textFieldStyle(.squareBorder)
          .focused($isNameFocused)
          .frame(maxWidth: 300)
        Button(action: {
          viewModel.generateName()
        }, label: { Image(systemName: "hands.sparkles.fill") })
      }
    }
    .onAppear {
      isNameFocused = true
    }
  }
}

fileprivate struct AvatarRowView: View {
  @ObservedObject var viewModel: ConfigureDetailsViewModel

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
    let selectedAvatarBinding = Binding(
      get: { viewModel.avatarImageName },
      set: { viewModel.avatarImageName = $0 }
    )
    LabeledCardView("Avatar") {
      AvatarPickerView(selectedAvatar: selectedAvatarBinding)
    }
  }
}


struct ConfigureDetailsView: View {
  var viewModel: ConfigureDetailsViewModel

  var body: some View {
    CardStack {
      CardStackText("Finish setting up your chat source by giving it some flair")
      DisplayNameRowView(viewModel: viewModel)
      AvatarRowView(viewModel: viewModel)
    }
    .padding()
  }
}
