//
//  PrimaryActionsView.swift
//  
//
//  Created by Alex Rozanski on 09/05/2023.
//

import SwiftUI

struct PrimaryActionsView: View {
  @ObservedObject var viewModel: PrimaryActionsViewModel

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
