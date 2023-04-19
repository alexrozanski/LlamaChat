//
//  SourcesSettingsDetailView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SourcesSettingsDetailView: View {
  enum Tab: CaseIterable {
    case properties
    case parameters

    var label: String {
      switch self {
      case .properties: return "Properties"
      case .parameters: return "Parameters"
      }
    }
  }

  var viewModel: SourcesSettingsDetailViewModel

  @State var selectedTab: Tab = .properties

  @ViewBuilder var tabContent: some View {
    switch selectedTab {
    case .properties:
      SourceSettingsPropertiesView(viewModel: viewModel)
    case .parameters:
      SourceSettingsParametersView(viewModel: viewModel.parametersViewModel)
    }
  }

  var body: some View {
    VStack {
      Picker("", selection: $selectedTab) {
        ForEach(Tab.allCases, id: \.self) { tab in
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
