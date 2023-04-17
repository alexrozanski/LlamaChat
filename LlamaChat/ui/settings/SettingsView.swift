//
//  SettingsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SettingsView: View {
  @ObservedObject var viewModel: SettingsViewModel

  init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
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
    .frame(idealWidth: 640, idealHeight: 380)
  }
}
