//
//  ConvertSourceStepViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 08/04/2023.
//

import Foundation
import Combine

class ConvertSourceStepViewModel: Identifiable, ObservableObject {
  typealias ExecutionHandler = (
    _ command: @escaping (String) -> Void,
    _ stdout: @escaping (String) -> Void,
    _ stderr: @escaping (String) -> Void,
    _ exitCode: @escaping (Int32) -> Void
  ) async throws -> Bool

  enum State {
    case notStarted
    case running
    case finished(result: Result<Void, Error>)

    var canStart: Bool {
      switch self {
      case .notStarted:
        return true
      case .running, .finished:
        return false
      }
    }
  }

  private enum OutputType {
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

  private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
  private var timerSubscription: AnyCancellable?
  private var subscriptions = Set<AnyCancellable>()

  @Published var state: State = .notStarted
  @Published private(set) var expanded = false

  @Published private(set) var output = ""
  @Published private(set) var exitCode: Int32?

  @Published private var startDate: Date?
  @Published private var runUntilDate: Date?
  @Published var runTime: Double?

  private var lastOutputType: OutputType?

  let id: String
  let label: String
  let executionHandler: ExecutionHandler

  init(label: String, executionHandler: @escaping ExecutionHandler) {
    self.id = UUID().uuidString
    self.label = label
    self.executionHandler = executionHandler
    $startDate
      .combineLatest($runUntilDate)
      .sink { [weak self] startDate, endDate in
        if let startDate, let endDate {
          self?.runTime = endDate.timeIntervalSince(startDate)
        } else {
          self?.runTime = nil
        }
      }.store(in: &subscriptions)

  }

  func start() {
    guard state.canStart else { return }

    state = .running
    startDate = Date()
    timerSubscription = timer.map { $0 as Date? }.assign(to: \.runUntilDate, on: self)

    Task.init {
      do {
        func makeAppend(prefix: String?, outputType: OutputType) -> ((String) -> Void) {
          return { [weak self] string in
            DispatchQueue.main.async { [weak self] in
              self?.appendOutput(string: string, outputType: outputType)
            }
          }
        }

        var exitCode: Int32 = -1
        _ = try await executionHandler(
          makeAppend(prefix: "> ", outputType: .command),
          makeAppend(prefix: nil, outputType: .stdout),
          makeAppend(prefix: nil, outputType: .stderr),
          { exitCode = $0 }
        )

        let newExitCode = exitCode
        await MainActor.run {
          self.exitCode = newExitCode
          state = .finished(result: newExitCode == 0 ? .success(()) : .failure(NSError()))
          if runUntilDate == nil {
            runUntilDate = Date()
          }
          timerSubscription = nil
        }
      } catch {
        await MainActor.run {
          state = .finished(result: .failure(error))
          if runUntilDate == nil {
            runUntilDate = Date()
          }
          timerSubscription = nil
        }
      }
    }
  }

  private func appendOutput(string: String, outputType: OutputType) {
    if outputType != lastOutputType && !output.isEmpty {
      output.append("\n")
    }

    if outputType.isCommand {
      output.append("> ")
    }
    output.append(string)
    if outputType.isCommand {
      output.append("\n")
    }
    lastOutputType = outputType
  }

  func toggleExpansion() {
    expanded = !expanded
  }
}
