//
//  SettingsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

public struct SettingsView: View {
  @ObservedObject public var viewModel: SettingsViewModel

  public init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
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
      SourcesSettingsView(viewModel: viewModel.sourcesSettingsViewModel)
        .tabItem {
          Label("Sources", systemImage: "ellipsis.bubble")
        }
        .tag(SettingsTab.sources)
    }
    .frame(minWidth: 800, idealWidth: 800, minHeight: 500, idealHeight: 500)
  }
}
