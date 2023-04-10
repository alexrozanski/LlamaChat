//
//  ConvertSourceStepViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import AppKit
import Foundation
import Combine
import llama

class ConvertSourceStepViewModel: Identifiable, ObservableObject {
  enum State {
    case notStarted
    case skipped
    case running
    case cancelled
    case finished(result: Result<Int32, Error>)

    var canStart: Bool {
      switch self {
      case .notStarted: return true
      case .skipped, .running, .cancelled, .finished: return false
      }
    }
  }

  enum OutputType {
    case command
    case stdout
    case stderr

    var isCommand: Bool {
      switch self {
      case .command:
        return true
      case .stdout, .stderr:
        return false
      }
    }
  }

  typealias ID = String

  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  private var timerSubscription: AnyCancellable?
  private var subscriptions = Set<AnyCancellable>()

  @Published private(set) var state: State = .notStarted
  @Published private(set) var exitCode: Int32?
  @Published private(set) var expanded = false

  @Published private(set) var textViewModel = NonEditableTextViewModel()
  @Published var runTime: Double?

  private var lastOutputType: OutputType?

  var label: String {
    switch conversionStep.type {
    case .checkEnvironment:
      return "Checking environment"
    case .setUpEnvironment:
      return "Setting up environment"
    case .checkDependencies:
      return "Checking dependencies"
    case .convertModel:
      return "Converting model"
    case .quantizeModel:
      return "Quantizing model"
    }
  }

  let id: ID
  private let conversionStep: AnyConversionStep<ConvertPyTorchToGgmlConversionStep>

  init(conversionStep: AnyConversionStep<ConvertPyTorchToGgmlConversionStep>) {
    self.id = UUID().uuidString
    self.conversionStep = conversionStep

    conversionStep.$state.receive(on: DispatchQueue.main).sink { [weak self] newState in
      guard let self else { return }

      switch newState {
      case .notStarted:
        self.state = .notStarted
        self.exitCode = nil
      case .skipped:
        self.state = .skipped
        self.exitCode = nil
      case .running:
        self.state = .running
        self.exitCode = nil
      case .cancelled:
        self.state = .cancelled
        self.exitCode = nil
      case .finished(result: let result):
        if let status = try? result.get(), status.exitCode == 0 {
          self.state = .finished(result: .success(status.exitCode))
          self.exitCode = status.exitCode
        } else {
          self.state = .finished(result: .success(1))
          self.exitCode = Int32(1)
        }
      }
    }.store(in: &subscriptions)

    $state.sink { newState in
      switch newState {
      case .notStarted, .skipped, .running, .cancelled:
        self.exitCode = nil
      case .finished(result: let result):
        switch result {
        case .success(let exitCode):
          self.exitCode = exitCode
        case .failure:
          self.exitCode = nil
        }
      }
    }.store(in: &subscriptions)

    conversionStep.$startDate
      .combineLatest(conversionStep.$runUntilDate)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] startDate, endDate in
        if let startDate, let endDate {
          self?.runTime = endDate.timeIntervalSince(startDate)
        } else {
          self?.runTime = nil
        }
      }.store(in: &subscriptions)

    conversionStep.commandOutput.sink { [weak self] output in self?.appendOutput(string: output, outputType: .command) }.store(in: &subscriptions)
    conversionStep.stdoutOutput.sink { [weak self] output in self?.appendOutput(string: output, outputType: .stdout) }.store(in: &subscriptions)
    conversionStep.stderrOutput.sink { [weak self] output in self?.appendOutput(string: output, outputType: .stderr) }.store(in: &subscriptions)
  }

  func toggleExpansion() {
    expanded = !expanded
  }

  private func appendOutput(string: String, outputType: OutputType) {
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
