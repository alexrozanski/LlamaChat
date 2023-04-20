//
//  SourcesSettingsDetailViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import AppKit
import Combine

class SourcesSettingsDetailViewModel: ObservableObject {
  enum Tab: CaseIterable {
    case properties
    case parameters
  }

  private let source: ChatSource

  var id: ChatSource.ID { source.id }

  @Published var selectedTab: Tab

  private(set) lazy var propertiesViewModel = SourceSettingsPropertiesViewModel(source: source)
  private(set) lazy var parametersViewModel = SourceSettingsParametersViewModel(modelParameters: source.modelParameters)

  init(source: ChatSource, selectedTab: Tab?) {
    self.source = source
    self.selectedTab = selectedTab ?? .properties
  }
}
