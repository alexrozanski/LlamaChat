//
//  SettingsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI
import ModelCompatibility

public struct SettingsView<ParametersContent>: View where ParametersContent: View {
  public typealias ParametersContentBuilder = (ModelParametersViewModel?) -> ParametersContent

  @ObservedObject public var viewModel: SettingsViewModel
  public let parametersContent: ParametersContentBuilder

  public init(
    viewModel: SettingsViewModel,
    @ViewBuilder parametersContent: @escaping ParametersContentBuilder
  ) {
    self.viewModel = viewModel
    self.parametersContent = parametersContent
  }

  public var body: some View {
    let selectedTabBinding = Binding(
      get: { viewModel.selectedTab },
      set: { viewModel.selectedTab = $0 }
    )
    TabView(selection: selectedTabBinding) {
      GeneralSettingsView(viewModel: viewModel.generalSettingsViewModel)
        .tabItem {
          Label("General", systemImage: "gearshape")
        }
        .tag(SettingsTab.general)
      SourcesSettingsView(viewModel: viewModel.sourcesSettingsViewModel, parametersContent: parametersContent)
        .tabItem {
          Label("Sources", systemImage: "ellipsis.bubble")
        }
        .tag(SettingsTab.sources)
    }
    .frame(minWidth: 800, idealWidth: 800, minHeight: 500, idealHeight: 500)
  }
}
