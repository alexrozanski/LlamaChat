//
//  SourcesSettingsViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine
import AddSourceUI
import AppModel
import DataModel
import SharedUI

class SourcesSettingsSourceItemViewModel: ObservableObject {
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
}

class SourcesSettingsViewModel: ObservableObject {
  private let dependencies: Dependencies

  @Published var sources: [SourcesSettingsSourceItemViewModel]
  @Published var selectedSourceId: ChatSource.ID? {
    didSet {
      guard let selectedSourceId, let source = dependencies.chatSourcesModel.source(for: selectedSourceId) else {
        detailViewModel = nil
        return
      }

      let oldDetailViewModel = detailViewModel
      detailViewModel = SourcesSettingsDetailViewModel(
        source: source,
        selectedTab: oldDetailViewModel?.selectedTab ?? .properties,
        stateRestoration: dependencies.stateRestoration
      )
    }
  }

  @Published var detailViewModel: SourcesSettingsDetailViewModel?
  @Published var sheetViewModel: (any ObservableObject)?

  @Published var sheetPresented = false

  private var subscriptions = Set<AnyCancellable>()

  init(dependencies: Dependencies) {
    self.dependencies = dependencies
    self.sources = makeSourceItemViewModels(from: dependencies.chatSourcesModel.sources)

    dependencies.chatSourcesModel.$sources
      .map { makeSourceItemViewModels(from: $0) }
      .assign(to: &$sources)

    // bit hacky but use receive(on:) to ensure chatSourcesModel.sources has been updated to its new value
    // to ensure consistent state (otherwise in the `sink()` chatSourcesModel.sources will not have been updated yet.
    dependencies.chatSourcesModel.$sources
      .receive(on: DispatchQueue.main)
      .scan((nil as [ChatSource]?, dependencies.chatSourcesModel.sources)) { (previous, current) in
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

    $sheetViewModel
      .map { newSheetViewModel in
        return newSheetViewModel != nil
      }
      .assign(to: &$sheetPresented)
  }

  func moveSources(fromOffsets offsets: IndexSet, toOffset destination: Int) {
    dependencies.chatSourcesModel.moveSources(fromOffsets: offsets, toOffset: destination)
  }

  func remove(_ source: ChatSource) {
    dependencies.chatSourcesModel.remove(source: source)
  }

  func selectFirstSourceIfEmpty() {
    if selectedSourceId == nil {
      selectedSourceId = sources.first?.id
    }
  }

  func showAddSourceSheet() {
    sheetViewModel = AddSourceViewModel(dependencies: dependencies, closeHandler: { [weak self] newSource in
      self?.sheetViewModel = nil
      if let newSource {
        self?.selectedSourceId = newSource.id
      }
    })
  }

  func showConfirmDeleteSourceSheet(forSourceWithId sourceId: ChatSource.ID) {
    guard let source = dependencies.chatSourcesModel.source(for: sourceId) else { return }

    sheetViewModel = ConfirmDeleteSourceSheetViewModel(
      chatSource: source,
      chatSourcesModel: dependencies.chatSourcesModel,
      closeHandler: { [weak self] in
        self?.sheetViewModel = nil
      }
    )
  }
}

fileprivate func makeSourceItemViewModels(from sources: [ChatSource]) -> [SourcesSettingsSourceItemViewModel] {
  return sources.map { SourcesSettingsSourceItemViewModel(source: $0) }
}
