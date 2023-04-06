//
//  ConfigureLocalModelPathSelectorView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation

class ConfigureLocalModelPathSelectorViewModel: ObservableObject {
  enum ModelState {
    case none
    case invalid(message: String)
    case valid
  }

  enum SelectionMode {
    case files
    case directories
  }

  @Published var modelPaths: [String] = []
  @Published var modelState: ModelState = .none

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
