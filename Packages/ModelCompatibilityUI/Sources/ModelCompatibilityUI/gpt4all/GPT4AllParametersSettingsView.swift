//
//  GPT4AllParametersSettingsView.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import SwiftUI
import SettingsUI
import SharedUI

public struct GPT4AllParametersSettingsView: View {
  @ObservedObject var viewModel: GPT4AllModelParametersViewModel

  @ViewBuilder var basicParameters: some View {
    Section {
      DiscreteSliderRowView(
        value: $viewModel.numberOfTokens.toInt(),
        range: 128...2048,
        isExponential: true,
        numberOfTickMarks: 5,
        label: {
          ParameterLabelWithDescription(
            label: "Number of Tokens",
            description: "The maximum number of tokens to output for each response."
          )
        }
      )
    }
  }

  @ViewBuilder var samplingParameters: some View {
    Section("Sampling Parameters") {
      ContinuousSliderRowView(
        value: $viewModel.topP,
        range: 0...1,
        fractionDigits: 2,
        numberOfTickMarks: 5,
        label: {
          ParameterLabelWithDescription(
            label: "Top-p",
            description: "The value used in top-p sampling."
          )
        }
      )
      DiscreteSliderRowView(
        value: $viewModel.topK.toInt(),
        range: 1...10000,
        numberOfTickMarks: 11,
        label: {
          ParameterLabelWithDescription(
            label: "Top-k",
            description: "The value used in top-k sampling."
          )
        }
      )
      ContinuousSliderRowView(
        value: $viewModel.temperature,
        range: 0...2,
        fractionDigits: 2,
        numberOfTickMarks: 5,
        label: {
          ParameterLabelWithDescription(
            label: "Temperature",
            description: "A scaling factor controlling the level of randomness and diversity."
          )
        }
      )
      DiscreteSliderRowView(
        value: $viewModel.batchSize.toInt(),
        range: 1...256,
        isExponential: true,
        numberOfTickMarks: 9,
        label: {
          ParameterLabelWithDescription(
            label: "Batch Size",
            description: "The batch size used when processing prompts."
          )
        }
      )
    }
  }

  @ViewBuilder var penalizationParameters: some View {
    Section("Penalization") {
      ContinuousSliderRowView(
        value: $viewModel.repeatPenalty,
        range: 1...2,
        numberOfTickMarks: 10,
        label: {
          ParameterLabelWithDescription(
            label: "Repeat Penalty",
            description: "The penalization value for repeated sequences of tokens."
          )
        }
      )
    }
  }

  public var body: some View {
    Form {
      basicParameters
      samplingParameters
      penalizationParameters
    }
    .formStyle(.grouped)
  }
}


