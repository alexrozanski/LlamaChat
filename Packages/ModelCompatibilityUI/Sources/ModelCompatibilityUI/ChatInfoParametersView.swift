//
//  ChatInfoParametersView.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import SwiftUI
import ModelCompatibility

public struct ChatInfoParametersView: View {
  let viewModel: ModelParametersViewModel?

  public init(viewModel: ModelParametersViewModel?) {
    self.viewModel = viewModel
  }

  public var body: some View {
    if let viewModel = viewModel as? LlamaFamilyModelParametersViewModel {
      LlamaFamilyModelParametersChatInfoView(viewModel: viewModel)
    }
  }
}
