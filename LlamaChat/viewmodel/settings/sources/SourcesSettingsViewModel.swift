//
//  SourcesSettingsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine

class SourcesSettingsSourceItemViewModel: ObservableObject, Equatable {
  fileprivate let source: ChatSource

  var id: String { source.id }
  @Published var title: String

  private var subscriptions = Set<AnyCancellable>()

  init(source: ChatSource) {
    self.source = source
    self.title = source.name
    source.$name.sink(receiveValue: { [weak self] newName in
      self?.title = newName
    }).store(in: &subscriptions)
  }

  static func == (lhs: SourcesSettingsSourceItemViewModel, rhs: SourcesSettingsSourceItemViewModel) -> Bool {
    return lhs.source == rhs.source
  }
}

class SourcesSettingsViewModel: ObservableObject {
  private let chatSources: ChatSources

  @Published var sources: [SourcesSettingsSourceItemViewModel]
  @Published var selectedSourceId: ChatSource.ID? {
    didSet {
      guard let selectedSourceId, let source = chatSources.source(for: selectedSourceId) else {
        detailViewModel = nil
        return
      }
      detailViewModel = SourcesSettingsDetailViewModel(source: source)
    }
  }

  @Published var detailViewModel: SourcesSettingsDetailViewModel?
  @Published var sheetViewModel: (any ObservableObject)?

  @Published var sheetPresented = false

  private var subscriptions = Set<AnyCancellable>()

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
    self.sources = chatSources.sources.map { SourcesSettingsSourceItemViewModel(source: $0) }

    chatSources.$sources.sink(receiveValue: { sources in
      self.sources = sources.map { SourcesSettingsSourceItemViewModel(source: $0) }
    }).store(in: &subscriptions)

    // bit hacky but use receive(on:) to ensure chatSources.sources has been updated to its new value
    // to ensure consistent state (otherwise in the `sink()` chatSources.sources will not have been updated yet.
    chatSources.$sources
      .receive(on: DispatchQueue.main)
      .scan((nil as [ChatSource]?, chatSources.sources)) { (previous, current) in
        let lastCurrent = previous.1
        return (lastCurrent, current)
      }
      .sink(receiveValue: { [weak self] previousSources, newSources in
        guard let self else { return }

        if newSources.count == 1 && (previousSources?.isEmpty ?? true) {
          self.selectedSourceId = newSources.first?.id
        }

        if !newSources.map({ $0.id }).contains(self.selectedSourceId) {
          self.selectedSourceId = nil
        }
      }).store(in: &subscriptions)

    $sheetViewModel.sink { [weak self] newSheetViewModel in
      self?.sheetPresented = newSheetViewModel != nil
    }.store(in: &subscriptions)
  }

  func remove(_ source: ChatSource) {
    chatSources.remove(source: source)
  }

  func selectFirstSource() {
    selectedSourceId = sources.first?.id
  }

  func showAddSourceSheet() {
    sheetViewModel = AddSourceViewModel(chatSources: chatSources, closeHandler: { [weak self] newSource in
      self?.sheetViewModel = nil
      if let newSource {
        self?.selectedSourceId = newSource.id
      }
    })
  }

  func showConfirmDeleteSourceSheet(forSourceWithId sourceId: ChatSource.ID) {
    guard let source = chatSources.source(for: sourceId) else { return }

    sheetViewModel = ConfirmDeleteSourceSheetViewModel(
      chatSource: source,
      chatSources: chatSources,
      closeHandler: { [weak self] in
        self?.sheetViewModel = nil
      }
    )
  }
}
