//
//  Sliders.swift
//  
//
//  Created by Alex Rozanski on 11/05/2023.
//

import SwiftUI
import SharedUI

public struct DiscreteSliderRowView<Label>: View where Label: View {
  public typealias LabelBuilder = () -> Label

  let value: Binding<Int>
  let range: ClosedRange<Int>
  var isExponential: Bool
  var numberOfTickMarks: Int?

  @ViewBuilder var label: LabelBuilder

  public init(
    value: Binding<Int>,
    range: ClosedRange<Int>,
    isExponential: Bool = false,
    numberOfTickMarks: Int? = nil,
    @ViewBuilder label: @escaping LabelBuilder
  ) {
    self.value = value
    self.range = range
    self.isExponential = isExponential
    self.numberOfTickMarks = numberOfTickMarks
    self.label = label
  }

  public var body: some View {
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

public struct ContinuousSliderRowView<Label>: View where Label: View {
  public typealias LabelBuilder = () -> Label

  let value: Binding<Double>
  let range: ClosedRange<Double>
  var fractionDigits: Int
  var numberOfTickMarks: Int?
  @ViewBuilder var label: LabelBuilder

  public init(
    value: Binding<Double>,
    range: ClosedRange<Double>,
    fractionDigits: Int = 1,
    numberOfTickMarks: Int? = nil,
    @ViewBuilder label: @escaping LabelBuilder
  ) {
    self.value = value
    self.range = range
    self.fractionDigits = fractionDigits
    self.numberOfTickMarks = numberOfTickMarks
    self.label = label
  }

  public var body: some View {
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
