//
//  VariantPickerViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import Foundation
import DataModel

class VariantPickerViewModel: ObservableObject {
  typealias LabelProvider = (ModelVariant?) -> String

  @Published var selectedVariant: ModelVariant? = nil

  var emptySelectionLabel: String {
    return labelProvider?(nil) ?? "Unknown"
  }

  let label: String
  let labelProvider: LabelProvider?
  let variants: [ModelVariant]

  init(
    label: String,
    labelProvider: LabelProvider? = nil,
    variants: [ModelVariant]
  ) {
    self.label = label
    self.labelProvider = labelProvider
    self.variants = variants
  }

  func label(for variant: ModelVariant) -> String {
    return labelProvider?(variant) ?? variant.name
  }

  func select(variantId: String) {
    if variantId.isEmpty {
      selectedVariant = nil
    } else {
      selectedVariant = variants.first { $0.id == variantId }
    }
  }
}
