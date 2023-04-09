//
//  ConvertStep.swift
//  CamelChat
//
//  Created by Alex Rozanski on 09/04/2023.
//

import AppKit
import Foundation
import Combine
import llama

class ConvertStep: ObservableObject {
  typealias CompletionHandler = (Status) -> Void

  enum Status {
    case skipped
    case success
    case failure(exitCode: Int32)

    init(exitCode: Int32) {
      self = exitCode == 0 ? .success : .failure(exitCode: exitCode)
    }

    var exitCode: Int32? {
      switch self {
      case .skipped: return nil
      case .success: return 0
      case .failure(exitCode: let exitCode): return exitCode
      }
    }

    var isSuccess: Bool {
      switch self {
      case .success: return true
      case .failure, .skipped: return false
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

  typealias ExecutionHandler = (
    _ command: @escaping (String) -> Void,
    _ stdout: @escaping (String) -> Void,
    _ stderr: @escaping (String) -> Void
  ) async throws -> Int32
  typealias CommandConnectedExecutionHandler = (CommandConnectors) async throws -> Int32

  enum State {
    case notStarted
    case skipped
    case running
    case finished(result: Result<Status, Error>)

    var canStart: Bool {
      switch self {
      case .notStarted: return true
      case .skipped, .running, .finished: return false
      }
    }

    var isFinished: Bool {
      switch self {
      case .notStarted, .running: return false
      case .skipped, .finished: return true
      }
    }
  }

  @Published var state: State = .notStarted
  @Published private(set) var startDate: Date?
  @Published private(set) var runUntilDate: Date?

  let commandOutput = PassthroughSubject<String, Never>()
  let stdoutOutput = PassthroughSubject<String, Never>()
  let stderrOutput = PassthroughSubject<String, Never>()  

  let label: String
  let executionHandler: ExecutionHandler
  
  init(
    label: String,
    executionHandler: @escaping ExecutionHandler
  ) {
    self.label = label
    self.executionHandler = executionHandler
  }

  convenience init(
    label: String,
    withCommandConnectors commandConnectedExecutionHandler: @escaping CommandConnectedExecutionHandler
  ) {
    self.init(label: label, executionHandler: { command, stdout, stderr in
      let commandConnectors = CommandConnectors(command: command, stdout: stdout, stderr: stderr)
      return try await commandConnectedExecutionHandler(commandConnectors)
    })
  }

  func run() {
    guard state.canStart else { return }

    state = .running
    startDate = Date()

    Task.init {
      func makeAppend(prefix: String?, outputType: OutputType) -> ((String) -> Void) {
        return { [weak self] string in
          DispatchQueue.main.async { [weak self] in
            self?.sendOutput(string: string, outputType: outputType)
          }
        }
      }

      let stderr = makeAppend(prefix: nil, outputType: .stderr)
      do {

        let exitCode = try await executionHandler(
          makeAppend(prefix: "> ", outputType: .command),
          makeAppend(prefix: nil, outputType: .stdout),
          stderr
        )
        await MainActor.run {
          // .success() is a bit misleading because the command could have failed, but
          // .success() indicates that *executing* the command succeeded.
          finish(with: .success(.init(exitCode: exitCode)))
        }
      } catch {
        await MainActor.run {
          stderr(error.localizedDescription)
          if let underlyingError = (error as NSError).underlyingErrors.first {
            stderr("\n\n\(underlyingError.localizedDescription)")
          }
          finish(with: .failure(error))
        }
      }
    }
  }

  func skip() {
    guard state.canStart else { return }

    sendOutput(string: "Skipped step", outputType: .stdout)
    state = .skipped
  }

  private func finish(with executionResult: Result<Status, Error>) {
    state = .finished(result: executionResult)
    if runUntilDate == nil {
      runUntilDate = Date()
    }
  }

  private func sendOutput(string: String, outputType: OutputType) {
    let outputString: String
    if outputType.isCommand {
      outputString = "> \(string)"
    } else {
      outputString = string
    }

    switch outputType {
    case .command:
      commandOutput.send(outputString)
    case .stdout:
      stdoutOutput.send(outputString)
    case .stderr:
      stderrOutput.send(outputString)
    }
  }
}
