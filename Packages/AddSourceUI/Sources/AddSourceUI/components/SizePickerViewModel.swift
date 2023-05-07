//
//  SizePickerViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import DataModel

class SizePickerViewModel: ObservableObject {
  typealias LabelProvider = (_ modelSize: ModelSize, _ defaultProvider: (ModelSize) -> String) -> String

  @Published var modelSize: ModelSize = .unknown

  private let labelProvider: LabelProvider

  init(labelProvider: LabelProvider? = nil) {
    self.labelProvider = labelProvider ?? { modelSize, _ in
      defaultLabelProvider(modelSize)
    }
  }

  func label(for modelSize: ModelSize) -> String {
    labelProvider(modelSize, defaultLabelProvider)
  }
}

private func defaultLabelProvider(_ modelSize: ModelSize) -> String {
  switch modelSize {
  case .unknown: return "Unknown"
  case .size7B: return "7B"
  case .size13B: return "13B"
  case .size30B: return "30B"
  case .size65B: return "65B"
  }
}
