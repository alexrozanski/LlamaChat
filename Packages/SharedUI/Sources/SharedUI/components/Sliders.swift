//
//  Sliders.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 19/04/2023.
//

import SwiftUI

private let sliderLabelWidth = Double(40)

fileprivate struct WrappedNSSlider: NSViewRepresentable {
  var value: Binding<Double>
  var range: ClosedRange<Double>
  var numberOfTickMarks: Int?

  func makeNSView(context: Context) -> NSSlider {
    let slider = NSSlider()
    slider.minValue = range.lowerBound
    slider.maxValue = range.upperBound
    slider.numberOfTickMarks = numberOfTickMarks ?? 0
    slider.target = context.coordinator
    slider.action = #selector(Coordinator.valueChanged(_:))

    return slider
  }

  func updateNSView(_ nsView: NSSlider, context: Context) {
    nsView.doubleValue = value.wrappedValue
    nsView.numberOfTickMarks = numberOfTickMarks ?? 0
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(self)
  }

  class Coordinator {
    private var lastHapticFeedbackMarkerPosition: Double?

    let parent: WrappedNSSlider
    init(_ parent: WrappedNSSlider) {
      self.parent = parent
    }

    @objc func valueChanged(_ sender: NSSlider) {
      let currentValue = sender.doubleValue
      if sender.numberOfTickMarks > 0 {
        let closest = sender.closestTickMarkValue(toValue: currentValue)
        if abs(closest - currentValue) < Double.ulpOfOne && lastHapticFeedbackMarkerPosition != closest {
          NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .drawCompleted)
          lastHapticFeedbackMarkerPosition = closest
        }

        if abs(closest - currentValue) > 0.01 {
          lastHapticFeedbackMarkerPosition = nil
        }
      }

      parent.value.wrappedValue = currentValue
    }
  }
}

public struct DiscreteSliderView: View {
  var value: Binding<Int>
  var range: ClosedRange<Int>
  var isExponential: Bool = false
  var numberOfTickMarks: Int?

  public init(value: Binding<Int>, range: ClosedRange<Int>, isExponential: Bool, numberOfTickMarks: Int? = nil) {
    self.value = value
    self.range = range
    self.isExponential = isExponential
    self.numberOfTickMarks = numberOfTickMarks
  }

  public var body: some View {
    if isExponential {
      let wrappedValue = Binding<Double>(
        // Take the log_2() value of the wrapped value and scale back to 0...1 by using the log_2() of the upper bound and lower bound.
        get: {
          let top = log2(Double(value.wrappedValue)) - log2(Double(range.lowerBound))
          let bottom = log2(Double(range.upperBound)) - log2(Double(range.lowerBound))
          return top / bottom
        },
        // Inverse function, simplified.
        set: { value.wrappedValue = Int(pow(Double(range.upperBound), $0) * pow(Double(range.lowerBound), (1.0 - $0))) }
      )
      HStack {
        Text("\(range.lowerBound)")
          .font(.footnote)
          .frame(width: sliderLabelWidth, alignment: .trailing)
        WrappedNSSlider(value: wrappedValue, range: 0...1, numberOfTickMarks: numberOfTickMarks)
        Text("\(range.upperBound, specifier: "%d")")
          .font(.footnote)
          .frame(width: sliderLabelWidth, alignment: .leading)
      }
    } else {
      let wrappedValue = Binding<Double>(
        get: { Double(value.wrappedValue) },
        set: { value.wrappedValue = Int($0) }
      )
      HStack {
        Text("\(range.lowerBound)")
          .font(.footnote)
          .frame(width: sliderLabelWidth, alignment: .trailing)
        WrappedNSSlider(value: wrappedValue, range: (Double(range.lowerBound)...Double(range.upperBound)), numberOfTickMarks: numberOfTickMarks)
        Text("\(range.upperBound, specifier: "%d")")
          .font(.footnote)
          .frame(width: sliderLabelWidth, alignment: .leading)
      }
    }
  }
}

public struct ContinuousSliderView: View {
  var value: Binding<Double>
  var range: ClosedRange<Double>
  var numberOfTickMarks: Int?

  public init(value: Binding<Double>, range: ClosedRange<Double>, numberOfTickMarks: Int? = nil) {
    self.value = value
    self.range = range
    self.numberOfTickMarks = numberOfTickMarks
  }

  public var body: some View {
    HStack {
      Text("\(range.lowerBound, specifier: "%.1f")")
        .font(.footnote)
        .frame(width: sliderLabelWidth, alignment: .trailing)
      WrappedNSSlider(value: value, range: range, numberOfTickMarks: numberOfTickMarks)
      Text("\(range.upperBound, specifier: "%.1f")")
        .font(.footnote)
        .frame(width: sliderLabelWidth, alignment: .leading)
    }
  }
}
