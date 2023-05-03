//
//  SourcesSettingsDetailViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit
import Combine
import DataModel

class SourcesSettingsDetailViewModel: ObservableObject {
  enum Tab: CaseIterable {
    case properties
    case parameters
  }

  private let source: ChatSource
  private let stateRestoration: StateRestoration

  var id: ChatSource.ID { source.id }

  @Published var selectedTab: Tab

  private(set) lazy var propertiesViewModel = SourceSettingsPropertiesViewModel(source: source)
  private(set) lazy var parametersViewModel = SourceSettingsParametersViewModel(source: source, stateRestoration: stateRestoration)

  init(source: ChatSource, selectedTab: Tab?, stateRestoration: StateRestoration) {
    self.source = source
    self.selectedTab = selectedTab ?? .properties
    self.stateRestoration = stateRestoration
  }
}
