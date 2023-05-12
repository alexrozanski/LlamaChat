//
//  SourceSettingsParametersView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 19/04/2023.
//

import SwiftUI
import ModelCompatibility
import SharedUI

struct SourceSettingsParametersView<ParametersContent>: View where ParametersContent: View {
  @ObservedObject var viewModel: SourceSettingsParametersViewModel
  let parametersContent: (ModelParametersViewModel?) -> ParametersContent

  @State var showResetDefaultsAlert = false

  var body: some View {
    VStack {
      HStack {
        Toggle("Parameter Details", isOn: $viewModel.showDetails)
          .toggleStyle(.switch)
          .controlSize(.small)
          .padding(.leading, 8)
        Spacer()
        Button("Reset Defaults") {
          showResetDefaultsAlert = true
        }
        .alert(isPresented: $showResetDefaultsAlert) {
          Alert(
            title: Text("Reset parameters to defaults?"),
            message: Text("This cannot be undone"),
            primaryButton: .destructive(Text("Reset"), action: { viewModel.resetDefaults() }),
            secondaryButton: .cancel()
          )
        }
        .controlSize(.small)
      }
      .padding(.horizontal, 20)
      parametersContent(viewModel.parametersViewModel.value)
      .environment(\.showParameterDetails, viewModel.showDetails)
    }
  }
}
