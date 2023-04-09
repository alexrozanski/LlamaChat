//
//  ConvertSourceStepViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import AppKit
import Foundation
import Combine
import llama

class ConvertSourceStepViewModel: Identifiable, ObservableObject {
  typealias ID = String

  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  private var timerSubscription: AnyCancellable?
  private var subscriptions = Set<AnyCancellable>()

  @Published private(set) var state: ConvertStep.State
  @Published private(set) var exitCode: Int32?
  @Published private(set) var expanded = false

  @Published private(set) var textViewModel = NonEditableTextViewModel()
  @Published var runTime: Double?

  private var lastOutputType: ConvertStep.OutputType?

  var label: String {
    return convertStep.label
  }

  let id: ID
  private let convertStep: ConvertStep

  init(convertStep: ConvertStep) {
    self.id = UUID().uuidString
    self.convertStep = convertStep

    self.state = convertStep.state

    convertStep.$startDate
      .combineLatest(convertStep.$runUntilDate)
      .sink { [weak self] startDate, endDate in
        if let startDate, let endDate {
          self?.runTime = endDate.timeIntervalSince(startDate)
        } else {
          self?.runTime = nil
        }
      }.store(in: &subscriptions)
    convertStep.$state.sink { [weak self] newState in
      guard let self else { return }

      self.state = newState

      switch newState {
      case .notStarted, .skipped, .running:
        self.exitCode = nil
      case .finished(result: let result):
        if let status = try? result.get() {
          self.exitCode = status.exitCode
        } else {
          self.exitCode = Int32(1)
        }
      }
    }.store(in: &subscriptions)
    convertStep.commandOutput.sink { [weak self] output in self?.appendOutput(string: output, outputType: .command) }.store(in: &subscriptions)
    convertStep.stdoutOutput.sink { [weak self] output in self?.appendOutput(string: output, outputType: .stdout) }.store(in: &subscriptions)
    convertStep.stderrOutput.sink { [weak self] output in self?.appendOutput(string: output, outputType: .stderr) }.store(in: &subscriptions)
  }

  func toggleExpansion() {
    expanded = !expanded
  }

  private func appendOutput(string: String, outputType: ConvertStep.OutputType) {
    if outputType != lastOutputType && !textViewModel.isEmpty {
      textViewModel.append(attributedString: NSAttributedString(string: "\n"))
    }

    var color: NSColor?
    switch outputType {
    case .command: color = NSColor.controlTextColor
    case .stdout: color = .gray
    case .stderr: color = .red
    }

    textViewModel.append(attributedString: makeFormattedText(string: string, color: color))
    lastOutputType = outputType
  }
}

private func makeFormattedText(string: String, color: NSColor? = nil) -> NSAttributedString {
  var attributes = [NSAttributedString.Key: Any]()
  attributes[.font] = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
  if let color {
    attributes[.foregroundColor] = color
  }

  return NSAttributedString(string: string, attributes: attributes)
}
