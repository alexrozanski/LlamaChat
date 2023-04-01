//
//  SourcesSettingsViewModel.swift
//  CamelChat
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
  @Published var selectedSource: SourcesSettingsSourceItemViewModel?

  @Published var activeSheetViewModel: SheetViewModel?

  private var subscriptions = Set<AnyCancellable>()

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
    self.sources = chatSources.sources.map { SourcesSettingsSourceItemViewModel(source: $0) }
    chatSources.$sources.sink(receiveValue: { sources in
      self.sources = sources.map { SourcesSettingsSourceItemViewModel(source: $0) }
    }).store(in: &subscriptions)
  }

  func remove(_ source: ChatSource) {
    chatSources.remove(source: source)
  }

  func showAddSourceSheet() {
    activeSheetViewModel = AddSourceSheetViewModel(chatSources: chatSources, closeHandler: { [weak self] in
      self?.activeSheetViewModel = nil
    })
  }

  func showConfirmDeleteSourceSheet(for viewModel: SourcesSettingsSourceItemViewModel) {
    activeSheetViewModel = ConfirmDeleteSourceSheetViewModel(
      chatSource: viewModel.source,
      chatSources: chatSources,
      closeHandler: { [weak self] in
        self?.activeSheetViewModel = nil
      }
    )
  }

  func makeSelectedSourceDetailViewModel() -> SourcesSettingsDetailViewModel? {
    return selectedSource.map { SourcesSettingsDetailViewModel(source: $0.source) }
  }
}
