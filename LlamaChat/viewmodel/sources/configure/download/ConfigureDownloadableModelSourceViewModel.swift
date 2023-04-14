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
  enum State {
    case none
    case checkingReachability
    case readyToDownload(contentLength: Int64?)
    case downloadingModel(downloadedBytes: Int64?, totalBytes: Int64?, estimatedTimeRemaining: TimeInterval?)
    case downloadedModel(url: URL)
    case failedToDownload(error: Error)
    case cannotDownload

    var canStart: Bool {
      switch self {
      case .none:
        return true
      case .checkingReachability, .readyToDownload, .cannotDownload, .downloadedModel, .failedToDownload, .downloadingModel:
        return false
      }
    }

    var isCheckingReachability: Bool {
      switch self {
      case .none, .readyToDownload, .cannotDownload, .downloadedModel, .failedToDownload, .downloadingModel:
        return false
      case .checkingReachability:
        return true
      }
    }
  }

  @Published var state: State = .none

  private(set) lazy var availableSpace: Int64? = {
    return DownloadsManager.availableCapacity
  }()

  enum DownloadProgress {
    case nonDeterministic
    case deterministic(downloadedBytes: Int64, totalBytes: Int64, progress: Double, estimatedTimeRemaining: TimeInterval?)
  }

  @Published var downloadProgress: DownloadProgress?

  let chatSourceType: ChatSourceType
  let modelSize: ModelSize
  let downloadURL: URL

  let detailsViewModel: ConfigureSourceDetailsViewModel
  let primaryActionsViewModel = ConfigureSourcePrimaryActionsViewModel()

  private let nextHandler: ConfigureSourceNextHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    defaultName: String? = nil,
    chatSourceType: ChatSourceType,
    modelSize: ModelSize,
    downloadURL: URL,
    nextHandler: @escaping ConfigureSourceNextHandler
  ) {
    self.chatSourceType = chatSourceType
    self.modelSize = modelSize
    self.downloadURL = downloadURL
    self.detailsViewModel = ConfigureSourceDetailsViewModel(defaultName: defaultName, chatSourceType: chatSourceType)
    self.nextHandler = nextHandler
  }

  func start() {
    guard state.canStart else { return }

    state = .checkingReachability

    Task.init {
      let reachability = await DownloadsManager.checkReachability(of: downloadURL)
      await MainActor.run {
        switch reachability {
        case .reachable(contentLength: let contentLength):
          state = .readyToDownload(contentLength: contentLength)
        case .notReachable:
          state = .cannotDownload
        }
      }
    }

    $state.map { newState -> PrimaryActionsButton? in
      switch newState {
      case .none, .checkingReachability, .cannotDownload:
        return nil
      case .readyToDownload:
        return PrimaryActionsButton(title: "Start") { [weak self] in self?.startDownload() }
      case .downloadingModel, .failedToDownload:
        return PrimaryActionsButton(title: "Continue", disabled: true, action: {})
      case .downloadedModel(url: let url):
        return PrimaryActionsButton(title: "Continue") { [weak self] in
          guard let self else { return }
          let configuredSource = ConfiguredSource(
            name: self.detailsViewModel.name,
            avatarImageName: self.detailsViewModel.avatarImageName,
            settings: .downloadedFile(fileURL: url, modelSize: self.modelSize)
          )
          self.nextHandler(configuredSource)
        }
      }
    }
    .receive(on: DispatchQueue.main)
    .assign(to: &primaryActionsViewModel.$continueButton)

    $state.map { state in
      switch state {
      case .none, .checkingReachability, .readyToDownload, .downloadedModel, .failedToDownload, .cannotDownload:
        return DownloadProgress?.none
      case .downloadingModel(downloadedBytes: let downloadedBytes, totalBytes: let totalBytes, estimatedTimeRemaining: let estimatedTimeRemaining):
        if let downloadedBytes, let totalBytes {
          return .deterministic(
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
            progress: Double(downloadedBytes) / Double(totalBytes),
            estimatedTimeRemaining: estimatedTimeRemaining
          )
        } else {
          return .nonDeterministic
        }
      }
    }.assign(to: &$downloadProgress)
  }

  func startDownload() {
    switch state {
    case .none, .checkingReachability, .downloadingModel, .downloadedModel, .cannotDownload, .failedToDownload:
      break
    case .readyToDownload:
      Task.init {
        do {
          let downloadURL = try await DownloadsManager.shared.downloadFile(from: downloadURL, progressHandler: { [weak self] progress in
            self?.state = .downloadingModel(
              downloadedBytes: Int64(progress.completedUnitCount),
              totalBytes: Int64(progress.totalUnitCount),
              estimatedTimeRemaining: progress.estimatedTimeRemaining
            )
          })

          await MainActor.run {
            state = .downloadedModel(url: downloadURL)
          }
        } catch {
          await MainActor.run {
            state = .failedToDownload(error: error)
          }
        }
      }
      state = .downloadingModel(downloadedBytes: nil, totalBytes: nil, estimatedTimeRemaining: nil)
    }
  }
}
