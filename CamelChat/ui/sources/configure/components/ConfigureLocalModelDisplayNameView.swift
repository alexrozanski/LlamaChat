//
//  ConfigureModelDisplayNameView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct ConfigureModelDisplayNameView: View {
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
