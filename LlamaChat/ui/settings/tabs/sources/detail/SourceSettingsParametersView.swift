//
//  SourceSettingsParametersView.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 19/04/2023.
//

import SwiftUI

fileprivate struct DiscreteSliderRowView<Label>: View where Label: View {
  typealias LabelBuilder = () -> Label

  let value: Binding<Int>
  let range: ClosedRange<Int>
  var isExponential: Bool = false
  var numberOfTickMarks: Int? = nil

  @ViewBuilder var label: LabelBuilder

  var body: some View {
    let formatter: NumberFormatter = {
      let numberFormatter = NumberFormatter()
      numberFormatter.minimum = NSNumber(integerLiteral: range.lowerBound)
      numberFormatter.maximum = NSNumber(integerLiteral: range.upperBound)
      return numberFormatter
    }()
    LabeledContent(content: {
      HStack(spacing: 8) {
        DiscreteSliderView(value: value, range: range, isExponential: isExponential, numberOfTickMarks: numberOfTickMarks)
          .frame(maxWidth: .infinity)
        TextField("", value: value, formatter: formatter)
          .frame(width: 55)
          .controlSize(.small)
          .multilineTextAlignment(.center)
          .textFieldStyle(.roundedBorder)
      }
    }, label: label)
  }
}

fileprivate struct ParameterLabelWithDescription: View {
  let label: String
  let description: String

  @Environment(\.showParameterDetails) var showParameterDetails

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(label)
      if showParameterDetails {
        Text(description)
          .font(.footnote)
          .foregroundColor(.gray)
      }
    }
  }
}

fileprivate struct ContinuousSliderRowView<Label>: View where Label: View {
  typealias LabelBuilder = () -> Label

  let value: Binding<Double>
  let range: ClosedRange<Double>
  var fractionDigits: Int = 1
  var numberOfTickMarks: Int? = nil
  @ViewBuilder var label: LabelBuilder

  var body: some View {
    let formatter: NumberFormatter = {
      let numberFormatter = NumberFormatter()
      numberFormatter.minimum = NSNumber(floatLiteral: range.lowerBound)
      numberFormatter.maximum = NSNumber(floatLiteral: range.upperBound)
      numberFormatter.minimumFractionDigits = fractionDigits
      numberFormatter.maximumFractionDigits = fractionDigits
      return numberFormatter
    }()
    LabeledContent(content: {
      HStack(spacing: 8) {
        ContinuousSliderView(value: value, range: range, numberOfTickMarks: numberOfTickMarks)
          .frame(maxWidth: .infinity)
        TextField("", value: value, formatter: formatter)
          .frame(width: 55)
          .controlSize(.small)
          .multilineTextAlignment(.center)
          .textFieldStyle(.roundedBorder)
      }
    }, label: label)
  }
}

struct SourceSettingsParametersView: View {
  @ObservedObject var viewModel: SourceSettingsParametersViewModel

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
        value: $viewModel.contextSize,
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
        value: $viewModel.numberOfTokens,
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
        value: $viewModel.topK,
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
        value: $viewModel.batchSize,
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
        value: $viewModel.lastNTokensToPenalize,
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

  @State var showResetDefaultsAlert = false

  var body: some View {
    VStack {
      HStack {
        Toggle("Parameter Details", isOn: $viewModel.showDetails)
          .toggleStyle(.switch)
          .controlSize(.small)
          .padding(.leading, 8)
        Spacer()
        Button("Reset Defaults") {
          showResetDefaultsAlert = true
        }
        .alert(isPresented: $showResetDefaultsAlert) {
          Alert(
            title: Text("Reset parameters to defaults?"),
            message: Text("This cannot be undone"),
            primaryButton: .destructive(Text("Reset"), action: { viewModel.resetDefaults() }),
            secondaryButton: .cancel()
          )
        }
        .controlSize(.small)
      }
      .padding(.horizontal, 20)
      Form {
        basicParameters
        samplingParameters
        penalizationParameters
      }
      .formStyle(.grouped)
      .environment(\.showParameterDetails, viewModel.showDetails)
    }
  }
}

fileprivate struct ShowParameterDetailsKey: EnvironmentKey {
  static let defaultValue: Bool = false
}

fileprivate extension EnvironmentValues {
    var showParameterDetails: Bool {
        get { self[ShowParameterDetailsKey.self] }
        set { self[ShowParameterDetailsKey.self] = newValue }
    }
}
