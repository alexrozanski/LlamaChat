//
//  ConfigureDownloadableModelSourceViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import Combine
import SwiftUI

class ConfigureDownloadableModelSourceViewModel: ObservableObject, ConfigureSourceViewModel {
  typealias NextHandler = (ConfiguredSource) -> Void

  enum State {
    case none
    case checkingReachability
    case readyToDownload(contentLength: Int64?)
    case cannotDownload

    var canStart: Bool {
      switch self {
      case .none:
        return true
      case .checkingReachability, .readyToDownload, .cannotDownload:
        return false
      }
    }

    var isCheckingReachability: Bool {
      switch self {
      case .none, .readyToDownload, .cannotDownload:
        return false
      case .checkingReachability:
        return true
      }
    }
  }

  @Published var state: State = .none

  let chatSourceType: ChatSourceType
  let primaryActionsViewModel = ConfigureSourcePrimaryActionsViewModel()
  private let nextHandler: NextHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    chatSourceType: ChatSourceType,
    nextHandler: @escaping NextHandler
  ) {
    self.chatSourceType = chatSourceType
    self.nextHandler = nextHandler
    primaryActionsViewModel.delegate = self
  }

  func start() {
    guard state.canStart else { return }

    state = .checkingReachability

    Task.init {
      guard let url = URL(string: "https://gpt4all.io/ggml-gpt4all-j.bin") else { return }
      let reachability = await DownloadsManager().checkReachability(of: url)
      await MainActor.run {
        switch reachability {
        case .reachable(contentLength: let contentLength):
          state = .readyToDownload(contentLength: contentLength)
        case .notReachable:
          state = .cannotDownload
        }
      }
    }
  }
}

extension ConfigureDownloadableModelSourceViewModel: ConfigureSourcePrimaryActionsViewModelDelegate {
  func next() {
  }
}
