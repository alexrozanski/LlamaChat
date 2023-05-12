//
//  SourcesSettingsDetailView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI
import ModelCompatibility

struct SourcesSettingsDetailView<ParametersContent>: View where ParametersContent: View {
  @ObservedObject var viewModel: SourcesSettingsDetailViewModel
  let parametersContent: (ModelParametersViewModel?) -> ParametersContent

  @ViewBuilder var tabContent: some View {
    switch viewModel.selectedTab {
    case .properties:
      SourceSettingsPropertiesView(viewModel: viewModel.propertiesViewModel)
    case .parameters:
      SourceSettingsParametersView(viewModel: viewModel.parametersViewModel, parametersContent: parametersContent)
    }
  }

  var body: some View {
    VStack {
      Picker("", selection: $viewModel.selectedTab) {
        ForEach(SourcesSettingsDetailViewModel.Tab.allCases, id: \.self) { tab in
          Text(tab.label)
        }
      }
      .pickerStyle(.segmented)
      .fixedSize()
      tabContent
      Spacer()
    }
  }
}

fileprivate extension SourcesSettingsDetailViewModel.Tab {
  var label: String {
    switch self {
    case .properties: return "Properties"
    case .parameters: return "Parameters"
    }
  }
}
