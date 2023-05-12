//
//  ParametersSettingsView.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import SwiftUI
import ModelCompatibility

public struct ParametersSettingsView: View {
  let viewModel: ModelParametersViewModel?

  public init(viewModel: ModelParametersViewModel?) {
    self.viewModel = viewModel
  }

  public var body: some View {
    if let viewModel = viewModel as? LlamaFamilyModelParametersViewModel {
      // Bit finnicky -- we want to recreate the view when the parameters view model changes so use
      // `id` for this. Not ideal, hopefully we can improve this.
      LlamaFamilyParametersSettingsView(viewModel: viewModel)
        .id(viewModel.id)
    }
  }
}
