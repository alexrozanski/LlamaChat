//
//  ConfigureLocalModelPathSelectorView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation

class ConfigureLocalModelPathSelectorViewModel: ObservableObject {
  enum SelectionMode {
    case files
    case directories
  }

  @Published var modelPaths: [String] = []
  @Published var errorMessage: String?

  var label: String {
    return customLabel ?? (allowMultipleSelection ? "Model Paths" : "Model Path")
  }

  let selectionMode: SelectionMode
  let allowMultipleSelection: Bool
  let customLabel: String?

  init(customLabel: String? = nil, selectionMode: SelectionMode = .files, allowMultipleSelection: Bool = false) {
    self.customLabel = customLabel
    self.selectionMode = selectionMode
    self.allowMultipleSelection = allowMultipleSelection
  }
}
