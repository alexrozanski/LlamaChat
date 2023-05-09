//
//  VariantPickerView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI
import DataModel

struct VariantPickerView: View {
  @ObservedObject var viewModel: VariantPickerViewModel

  enum UnknownModelVariantAppearance {
    case regular
    case disabled

    var isDisabled: Bool {
      switch self {
      case .regular: return false
      case .disabled: return true
      }
    }
  }

  let enabled: Bool
  let unknownModelVariantAppearance: UnknownModelVariantAppearance

  init(
    viewModel: VariantPickerViewModel,
    enabled: Bool = true,
    unknownModelVariantAppearance: UnknownModelVariantAppearance
  ) {
    self.viewModel = viewModel
    self.enabled = enabled
    self.unknownModelVariantAppearance = unknownModelVariantAppearance
  }

  var body: some View {
    let selectionBinding = Binding<String>(
      get: { viewModel.selectedVariant?.id ?? "" },
      set: { viewModel.select(variantId: $0) }
    )

    Picker(viewModel.label, selection: selectionBinding) {
      Text(viewModel.emptySelectionLabel)
        .foregroundColor(unknownModelVariantAppearance.isDisabled ? Color(nsColor: NSColor.disabledControlTextColor) : nil)
        .tag("")
      if !unknownModelVariantAppearance.isDisabled {
        Divider()
      }
      ForEach(viewModel.variants, id: \.id) { variant in
        Text(viewModel.label(for: variant)).tag(variant.id)
      }
    }
    .disabled(!enabled)
  }
}
