//
//  MainChatViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 01/04/2023.
//

import Foundation
import Combine
import AppModel
import DataModel

class MainChatViewModel: ObservableObject {
  enum RestorableKey: String {
    case sidebarWidth
    case selectedSourceId
  }

  private let chatSourcesModel: ChatSourcesModel
  private let chatModels: ChatModels
  private let messagesModel: MessagesModel
  private let restorableData: any RestorableData<RestorableKey>

  @Published var selectedSourceId: ChatSource.ID? {
    didSet {
      restorableData.set(value: selectedSourceId, for: .selectedSourceId)
    }
  }
  @Published var sidebarWidth: Double? {
    didSet {
      restorableData.set(value: sidebarWidth, for: .sidebarWidth)
    }
  }

  @Published var sheetViewModel: (any ObservableObject)?
  @Published var sheetPresented = false

  lazy private(set) var chatListViewModel = ChatListViewModel(chatSourcesModel: chatSourcesModel, mainChatViewModel: self)

  private var subscriptions = Set<AnyCancellable>()

  init(
    chatSourcesModel: ChatSourcesModel,
    chatModels: ChatModels,
    messagesModel: MessagesModel,
    stateRestoration: StateRestoration
  ) {
    self.chatSourcesModel = chatSourcesModel
    self.chatModels = chatModels
    self.messagesModel = messagesModel
    self.restorableData = stateRestoration.restorableData(for: "ChatWindow")
    _sidebarWidth = Published(initialValue: restorableData.getValue(for: .sidebarWidth) ?? 200)
    _selectedSourceId = Published(initialValue: restorableData.getValue(for: .selectedSourceId) ?? chatSourcesModel.sources.first?.id)

    // bit hacky but use receive(on:) to ensure chatSourcesModel.sources has been updated to its new value
    // to ensure consistent state (otherwise in the `sink()` chatSourcesModel.sources will not have been updated yet.
    chatSourcesModel.$sources
      .receive(on: DispatchQueue.main)
      .scan((nil as [ChatSource]?, chatSourcesModel.sources)) { (previous, current) in
        let lastCurrent = previous.1
        return (lastCurrent, current)
      }
      .sink { [weak self] (previousSources, newSources) in
        guard let self else { return }

        if newSources.count == 1 && (previousSources?.isEmpty ?? true) {
          self.selectedSourceId = newSources.first?.id
        }

        if !newSources.map({ $0.id }).contains(self.selectedSourceId) {
          if let previousIndex = previousSources?.firstIndex(where: { $0.id == self.selectedSourceId }) {
            let nextIndex = previousIndex > 0 ? previousIndex - 1 : previousIndex
            self.selectedSourceId = nextIndex < newSources.count ? newSources[nextIndex].id : nil
          } else {
            self.selectedSourceId = newSources.first?.id
          }
        }
      }.store(in: &subscriptions)

    $sheetViewModel.sink { [weak self] newSheetViewModel in
      self?.sheetPresented = newSheetViewModel != nil
    }.store(in: &subscriptions)
  }  

  func makeChatViewModel(for sourceId: String) -> ChatViewModel? {
    guard let chatSource = chatSourcesModel.sources.first(where: { $0.id == sourceId }) else { return nil }
    return ChatViewModel(chatSource: chatSource, chatModels: chatModels, messagesModel: messagesModel)
  }

  func removeChatSource(_ chatSource: ChatSource) {
    sheetViewModel = ConfirmDeleteSourceSheetViewModel(
      chatSource: chatSource,
      chatSourcesModel: chatSourcesModel,
      closeHandler: { [weak self] in
        self?.sheetViewModel = nil
      }
    )
  }

  func presentAddSourceSheet() {
    sheetViewModel = AddSourceViewModel(chatSourcesModel: chatSourcesModel, closeHandler: { [weak self] _ in
      self?.sheetViewModel = nil
    })
  }

  func presentAddSourceSheetIfNeeded() {
    if chatSourcesModel.sources.isEmpty {
      presentAddSourceSheet()
    }
  }
}
