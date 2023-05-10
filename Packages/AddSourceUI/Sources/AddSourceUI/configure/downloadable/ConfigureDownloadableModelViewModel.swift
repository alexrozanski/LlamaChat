//
//  ConfigureDownloadableModelViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 14/04/2023.
//

import Foundation
import Combine
import SwiftUI
import DataModel
import Downloads
import ModelMetadata

class ConfigureDownloadableModelViewModel: ObservableObject {
  typealias ConfigureSourceNextHandler = (ConfiguredSource) -> Void

  enum State {
    case none
    case checkingReachability
    case readyToDownload(contentLength: Int64?)
    case downloadingModel(downloadHandle: DownloadHandle, downloadedBytes: Int64?, totalBytes: Int64?)
    case downloadedModel(url: URL)
    case failedToDownload(error: Error)
    case cannotDownload
  }

  @Published var state: State = .none

  var modelName: String {
    return model.name
  }

  var variantName: String {
    return modelVariant.name
  }

  private(set) lazy var availableSpace: Int64? = {
    return DownloadsManager.availableCapacity
  }()

  enum DownloadProgress {
    case nonDeterministic
    case deterministic(downloadedBytes: Int64, totalBytes: Int64, progress: Double)
  }

  @Published var downloadProgress: DownloadProgress?

  let model: Model
  let modelVariant: ModelVariant
  let downloadURL: URL

  let primaryActionsViewModel = PrimaryActionsViewModel()

  private let nextHandler: ConfigureSourceNextHandler

  private var subscriptions = Set<AnyCancellable>()

  init(
    defaultName: String? = nil,
    model: Model,
    modelVariant: ModelVariant,
    downloadURL: URL,
    nextHandler: @escaping ConfigureSourceNextHandler
  ) {
    self.model = model
    self.modelVariant = modelVariant
    self.downloadURL = downloadURL
    self.nextHandler = nextHandler
  }

  func start() {
    guard state.canStart else { return }

    state = .checkingReachability

    Task.init {
      let reachability = await DownloadsManager.checkReachability(of: downloadURL)
      await MainActor.run { [weak self] in
        switch reachability {
        case .reachable(contentLength: let contentLength):
          self?.state = .readyToDownload(contentLength: contentLength)
        case .notReachable:
          self?.state = .cannotDownload
        }
      }
    }

    $state.map { [weak self] newState in
      switch newState {
      case .none, .checkingReachability, .cannotDownload:
        return nil
      case .readyToDownload:
        return PrimaryActionsButton(title: "Download") { self?.startDownload() }
      case .downloadingModel, .failedToDownload:
        return PrimaryActionsButton(title: "Continue", disabled: true, action: {})
      case .downloadedModel(url: let url):
        return PrimaryActionsButton(title: "Continue") {
          guard let self else { return }
          let configuredSource = ConfiguredSource(
            model: self.model,
            modelVariant: self.modelVariant,
            settings: .downloadedFile(fileURL: url)
          )
          self.nextHandler(configuredSource)
        }
      }
    }
    .assign(to: &primaryActionsViewModel.$continueButton)

    $state.map { state in
      switch state {
      case .none, .checkingReachability, .readyToDownload, .downloadedModel, .failedToDownload, .cannotDownload:
        return DownloadProgress?.none
      case .downloadingModel(downloadHandle: _, downloadedBytes: let downloadedBytes, totalBytes: let totalBytes):
        if let downloadedBytes, let totalBytes {
          return .deterministic(
            downloadedBytes: downloadedBytes,
            totalBytes: totalBytes,
            progress: Double(downloadedBytes) / Double(totalBytes)
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
      let downloadHandle = DownloadsManager.shared.downloadFile(from: downloadURL, progressHandler: { [weak self] progress in
        self?.updateDownloadProgress(
          downloadedBytes: Int64(progress.completedUnitCount),
          totalBytes: Int64(progress.totalUnitCount)
        )
      }, resultsHandler: { [weak self] result in
        switch result {
        case .success(let downloadURL):
          self?.state = .downloadedModel(url: downloadURL)
        case .failure(let error):
          self?.state = .failedToDownload(error: error)
        }
      }, resultsHandlerQueue: .main)

      state = .downloadingModel(downloadHandle: downloadHandle, downloadedBytes: nil, totalBytes: nil)
    }
  }

  private func updateDownloadProgress(downloadedBytes: Int64, totalBytes: Int64) {
    // State hasn't been updated (or we have finished) so ignore this progress update.
    guard let downloadHandle = state.downloadHandle else { return }

    state = .downloadingModel(
      downloadHandle: downloadHandle,
      downloadedBytes: downloadedBytes,
      totalBytes: totalBytes
    )
  }
}

extension ConfigureDownloadableModelViewModel.State {
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

  var downloadHandle: DownloadHandle? {
    switch self {
    case .downloadingModel(downloadHandle: let downloadHandle, downloadedBytes: _, totalBytes: _):
      return downloadHandle
    case .none, .checkingReachability, .readyToDownload, .cannotDownload, .downloadedModel, .failedToDownload:
      return nil
    }
  }
}
