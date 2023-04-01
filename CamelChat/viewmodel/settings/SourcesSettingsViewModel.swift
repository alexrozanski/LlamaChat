//
//  SourcesSettingsViewModel.swift
//  CamelChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine

class SourcesSettingsViewModel: ObservableObject {
  private let chatSources: ChatSources

  @Published var sources: [ChatSource]
  @Published var selectedSource: ChatSource?

  @Published var activeSheetViewModel: SheetViewModel?

  private var subscriptions = Set<AnyCancellable>()

  init(chatSources: ChatSources) {
    self.chatSources = chatSources
    self.sources = chatSources.sources
    chatSources.$sources.sink(receiveValue: { sources in
      self.sources = sources
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

  func showConfirmDeleteSourceSheet(for source: ChatSource) {
    activeSheetViewModel = ConfirmDeleteSourceSheetViewModel(
      chatSource: source,
      chatSources: chatSources,
      closeHandler: { [weak self] in
        self?.activeSheetViewModel = nil
      }
    )
  }
}
