//
//  ConfigureSourcePrimaryActionsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 13/04/2023.
//

import SwiftUI

protocol ConfigureSourcePrimaryActionsViewModelDelegate: AnyObject {
  func next()
}

class ConfigureSourcePrimaryActionsViewModel: ObservableObject {
  @Published var showContinueButton: Bool = false
  @Published var canContinue: Bool = false
  @Published var nextButtonTitle: String = "Add"

  weak var delegate: ConfigureSourcePrimaryActionsViewModelDelegate?

  func next() {
    delegate?.next()
  }
}

struct ConfigureSourcePrimaryActionsView: View {
  @ObservedObject var viewModel: ConfigureSourcePrimaryActionsViewModel

  var body: some View {
    HStack {
      Spacer()
      if viewModel.showContinueButton {
        Button(viewModel.nextButtonTitle) {
          viewModel.next()
        }
        .keyboardShortcut(.return)
        .disabled(!viewModel.canContinue)
      }
    }
  }
}
