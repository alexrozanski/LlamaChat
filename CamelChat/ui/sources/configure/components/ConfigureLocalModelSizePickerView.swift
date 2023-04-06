//
//  ConfigureLocalModelSizePickerView.swift
//  CamelChat
//
//  Created by Alex Rozanski on 06/04/2023.
//

import SwiftUI

struct ConfigureLocalModelSizePickerView: View {
  @ObservedObject var viewModel: ConfigureLocalModelSizePickerViewModel

  enum UnknownModelSizeAppearance {
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
  let unknownModelSizeAppearance: UnknownModelSizeAppearance

  init(
    viewModel: ConfigureLocalModelSizePickerViewModel,
    enabled: Bool = true,
    unknownModelSizeAppearance: UnknownModelSizeAppearance
  ) {
    self.viewModel = viewModel
    self.enabled = enabled
    self.unknownModelSizeAppearance = unknownModelSizeAppearance
  }

  var body: some View {
    let modelTypeBinding = Binding(
      get: { viewModel.modelSize },
      set: { viewModel.modelSize = $0 }
    )
    Picker("Model Size", selection: modelTypeBinding) {
      Text(viewModel.label(for: .unknown))
        .foregroundColor(unknownModelSizeAppearance.isDisabled ? Color(NSColor.disabledControlTextColor.cgColor) : nil)
        .tag(ModelSize.unknown)
      if !unknownModelSizeAppearance.isDisabled {
        Divider()
      }
      ForEach([ModelSize.size7B, ModelSize.size13B, ModelSize.size30B, ModelSize.size65B]) { size in
        Text(viewModel.label(for: size)).tag(size)
      }
    }
    .disabled(!enabled)
  }
}
