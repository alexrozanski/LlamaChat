//
//  ConfigureLocalModelSourceView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct ConfigureLocalModelSourceView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSourceViewModel

  @State var selectedModelType: String = ""

  var body: some View {
    Form {
      ConfigureSourceDetailsView(viewModel: viewModel.detailsViewModel)
      SelectFormatView(viewModel: viewModel)

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
    .formStyle(.grouped)
  }
}
