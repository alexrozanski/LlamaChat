//
//  ConfigureLocalModelSourceView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct ConfigureLocalModelView: View {
  @ObservedObject var viewModel: ConfigureLocalModelViewModel

  var body: some View {
    VStack(spacing: 0) {
      SelectModelFormatView(viewModel: viewModel)

      if let settingsViewModel = viewModel.settingsViewModel {
        if let settingsViewModel = settingsViewModel as? ConfigureLocalGgmlModelSettingsViewModel {
          ConfigureLocalGgmlModelSettingsView(viewModel: settingsViewModel)
        } else if let settingsViewModel = settingsViewModel as? ConfigureLocalPyTorchModelSettingsViewModel {
          ConfigureLocalPyTorchModelSettingsView(viewModel: settingsViewModel)
        }
      }
    }
  }
}
