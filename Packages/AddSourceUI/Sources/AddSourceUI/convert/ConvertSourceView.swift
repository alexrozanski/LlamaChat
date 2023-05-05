//
//  ConvertSourceView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 07/04/2023.
//

import SwiftUI

struct ConvertSourceView: View {
  @ObservedObject var viewModel: ConvertSourceViewModel

  var body: some View {
    Form {
      switch viewModel.state {
      case .notStarted:
        Section {
          Text("LlamaChat will convert the PyTorch model weights to the .ggml format.\n\nAdditional disk space is required since the original file(s) are left untouched.")
        }
      case .converting, .failedToConvert, .finishedConverting:
        ForEach(viewModel.conversionSteps, id: \.id) { stepViewModel in
          ConvertSourceStepView(viewModel: stepViewModel)
        }
      }
    }
    .formStyle(.grouped)
    .navigationBarBackButtonHidden(viewModel.state.startedConverting)
  }
}
