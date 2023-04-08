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

  enum Status {
    case success
    case failure

    init(exitCode: Int32) {
      self = exitCode == 0 ? .success : .failure
    }

    var isSuccess: Bool {
      switch self {
      case .success: return true
      case .failure: return false
      }
    }
  }

  typealias ExecutionHandler = (
    _ command: @escaping (String) -> Void,
    _ stdout: @escaping (String) -> Void,
    _ stderr: @escaping (String) -> Void
  ) async throws -> Int32
  typealias CompletionHandler = (ID, Status) -> Void

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

  @Published private(set) var output = NSMutableAttributedString()
  @Published private(set) var exitCode: Int32?

  @Published private var startDate: Date?
  @Published private var runUntilDate: Date?
  @Published var runTime: Double?

  private var lastOutputType: OutputType?

  let id: ID
  let label: String
  let executionHandler: ExecutionHandler
  let completionHandler: CompletionHandler

  init(
    label: String,
    convertSourceViewModel: ConvertSourceViewModel,
    executionHandler: @escaping ExecutionHandler,
    completionHandler: @escaping CompletionHandler
  ) {
    self.id = UUID().uuidString
    self.label = label
    self.executionHandler = executionHandler
    self.completionHandler = completionHandler
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

        let exitCode = try await executionHandler(
          makeAppend(prefix: "> ", outputType: .command),
          makeAppend(prefix: nil, outputType: .stdout),
          makeAppend(prefix: nil, outputType: .stderr)
        )

        await MainActor.run {
          finish(with: .success(exitCode))
        }
      } catch {
        await MainActor.run {
          finish(with: .failure(error))
        }
      }
    }
  }

  private func finish(with result: Result<Int32, Error>) {
    let exitCode = (try? result.get()) ?? -1
    self.exitCode = exitCode
    state = .finished(result: result.map { _ in () })
    if runUntilDate == nil {
      runUntilDate = Date()
    }
    timerSubscription = nil
    completionHandler(id, Status(exitCode: exitCode))
  }

  private func appendOutput(string: String, outputType: OutputType) {
    var outputString: String = ""
    if outputType != lastOutputType && output.length > 0 {
      outputString += "\n"
    }

    if outputType.isCommand {
      outputString += "> "
    }
    outputString += string
    if outputType.isCommand {
      outputString += "\n"
    }

    var color: NSColor?
    switch outputType {
    case .command:
      color = nil
    case .stdout:
      color = .gray
    case .stderr:
      color = .red
    }

    output.append(makeFormattedText(string: outputString, color: color))
    lastOutputType = outputType
  }

  func toggleExpansion() {
    expanded = !expanded
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
