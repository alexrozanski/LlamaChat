//
//  SettingsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SettingsView: View {
  enum Tab {
    case sources
  }

  @ObservedObject var viewModel: SettingsViewModel

  init(viewModel: SettingsViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    TabView {
      SourcesSettingsView(viewModel: viewModel.sourcesSettingsViewModel)
        .tabItem {
          Label("Sources", systemImage: "ellipsis.bubble")
        }
        .tag(Tab.sources)
    }
  }
}
