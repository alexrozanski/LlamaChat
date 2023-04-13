//
//  ConvertSourcePrimaryActionsView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 13/04/2023.
//

import SwiftUI

struct ConvertSourcePrimaryActionsView: View {
  @ObservedObject var viewModel: ConvertSourceViewModel

  @ViewBuilder var primaryButton: some View {
    Button(action: {
      switch viewModel.state {
      case .finishedConverting:
        viewModel.finish()
      case .failedToConvert:
        viewModel.retryConversion()
      case .notStarted, .converting:
        viewModel.startConversion()
      }
    }) {
      switch viewModel.state {
      case .finishedConverting:
        Text("Finish")
      case .failedToConvert:
        Text("Retry")
      case .notStarted, .converting:
        Text("Start")
      }
    }
    .keyboardShortcut(.return)
    .disabled(viewModel.state.isConverting)
  }

  @ViewBuilder var stopButton: some View {
    Button(action: {
      viewModel.stopConversion()
    }) {
      Text("Stop")
    }
  }

  var body: some View {
    HStack {
      if viewModel.state.isConverting {
        stopButton
      }
      primaryButton
    }
  }
}
