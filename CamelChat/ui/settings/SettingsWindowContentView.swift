//
//  SettingsWindowContentView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import SwiftUI

struct SettingsWindowContentView: View {
  @ObservedObject var viewModel: SettingsWindowViewModel

  init(viewModel: SettingsWindowViewModel) {
    self.viewModel = viewModel
  }

  @ViewBuilder var content: some View {
    if let selectedTab = viewModel.selectedTab {
      switch selectedTab {
      case .sources:
        SourcesSettingsView(viewModel: viewModel.sourcesSettingsViewModel)
      }
    } else {
      EmptyView()
    }
  }

  var body: some View {
      content
        .frame(minWidth: 400, minHeight: 200)
        .onAppear {
          viewModel.select(tab: .sources)
        }
  }
}
