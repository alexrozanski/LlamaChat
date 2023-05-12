//
//  ParametersSettingsView.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import SwiftUI
import SettingsUI
import SharedUI

public struct LlamaFamilyParametersSettingsView: View {
  @ObservedObject var viewModel: LlamaFamilyModelParametersViewModel

  @ViewBuilder var basicParameters: some View {
    let seedBinding = Binding<NumericTextFieldWithRandomSelector.Value>(
      get: {
        if viewModel.isSeedRandom {
          return .random
        } else {
          return viewModel.seedValue.map({ .value(NSNumber(integerLiteral: Int($0))) }) ?? .random
        }
      },
      set: { newValue in
        switch newValue {
        case .random:
          viewModel.isSeedRandom = true
          viewModel.seedValue = nil
        case .value(let number):
          viewModel.isSeedRandom = false
          viewModel.seedValue = number.int32Value
        }
      }
    )
    Section {
      LabeledContent {
        // TODO: Remove this hack - can't get the alignment guides to work properly without a built-in component.
        Text("")
          .frame(maxWidth: .infinity)
          .overlay(
            NumericTextFieldWithRandomSelector(value: seedBinding, formatter: {
              let numberFormatter = NumberFormatter()
              numberFormatter.maximumFractionDigits = 0
              numberFormatter.minimumFractionDigits = 0
              return numberFormatter
            }())
            .padding(.leading, 20)
            .padding(.trailing, 4)
          )
      } label: {
        ParameterLabelWithDescription(
          label: "Seed",
          description: "The random number to seed text generation with."
        )
      }
      DiscreteSliderRowView(
        value: $viewModel.contextSize.toInt(),
        range: 128...2048,
        isExponential: true,
        numberOfTickMarks: 5,
        label: {
          ParameterLabelWithDescription(
            label: "Context Size",
            description: "The token 'memory' used when generating text."
          )
        }
      )
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
      DiscreteSliderRowView(
        value: $viewModel.lastNTokensToPenalize.toInt(),
        range: 1...256,
        isExponential: true,
        numberOfTickMarks: 9,
        label: {
          ParameterLabelWithDescription(
            label: "Penalization Window",
            description: "The last n number of tokens to consider for repetition penalization."
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


