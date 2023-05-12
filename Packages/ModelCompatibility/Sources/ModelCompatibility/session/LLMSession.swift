//
//  Session.swift
//  
//
//  Created by Alex Rozanski on 12/05/2023.
//

import Foundation
import Combine
import DataModel
import CameLLM
import CameLLMLlama

public enum LLMSessionState {
  case notStarted
  case loadingModel
  case readyToPredict
  case predicting
  case error(Error)
}

public enum LLMPredictionState {
  case notStarted
  case predicting
  case cancelled
  case finished
  case error(Error)
}

public class LLMSessionContext {
  public struct Token {
    public let value: Int32
    public let string: String
  }

  public var contextString: String? {
    return sessionContext.contextString
  }

  public private(set) lazy var tokens: [Token]? = {
    return sessionContext.tokens?.map { Token(value: $0.value, string: $0.string) }
  }()

  private let sessionContext: SessionContext

  init(sessionContext: SessionContext) {
    self.sessionContext = sessionContext
  }
}

public protocol LLMSessionDelegate: AnyObject {
  func llmSession(_ session: LLMSession, stateDidChange state: LLMSessionState)
  // Only called if the underlying session supports it.
  func llmSession(_ session: LLMSession, didUpdateSessionContext sessionContext: LLMSessionContext)
}

public protocol LLMSessionPredictionCancellable {
  func cancel()
}

final class ConcreteSessionPredictionCancellable: LLMSessionPredictionCancellable {
  private let _cancellable: PredictionCancellable
  init(cancellable: PredictionCancellable) {
    _cancellable = cancellable
  }

  func cancel() {
    _cancellable.cancel()
  }
}

public protocol LLMSession {
  var delegate: LLMSessionDelegate? { get }
  var state: LLMSessionState { get }

  func currentContext() async throws -> LLMSessionContext?

  func predict(
    with prompt: String,
    tokenHandler: @escaping (String) -> Void,
    stateChangeHandler: @escaping (LLMPredictionState) -> Void
  ) -> LLMSessionPredictionCancellable
}

public extension LLMSessionState {
  var isError: Bool {
    switch self {
    case .notStarted, .loadingModel, .predicting, .readyToPredict:
      return false
    case .error:
      return true
    }
  }
}
