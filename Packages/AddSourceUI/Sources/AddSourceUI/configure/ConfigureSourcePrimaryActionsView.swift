//
//  ConfigureSourcePrimaryActionsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 13/04/2023.
//

import SwiftUI

class PrimaryActionsButton {
  typealias Action = () -> Void

  let title: String
  let disabled: Bool
  let action: () -> Void

  init(title: String, disabled: Bool = false, action: @escaping Action) {
    self.title = title
    self.disabled = disabled
    self.action = action
  }
}

class ConfigureSourcePrimaryActionsViewModel: ObservableObject {
  @Published var continueButton: PrimaryActionsButton? = nil
  @Published var otherButtons: [PrimaryActionsButton] = []
}

struct ConfigureSourcePrimaryActionsView: View {
  @ObservedObject var viewModel: ConfigureSourcePrimaryActionsViewModel

  var body: some View {
    HStack {
      Spacer()
      if let continueButton = viewModel.continueButton {
        Button(continueButton.title) {
          continueButton.action()
        }
        .keyboardShortcut(.return)
        .disabled(continueButton.disabled)
      }
    }
  }
}
