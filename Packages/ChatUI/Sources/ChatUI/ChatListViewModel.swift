//
//  ChatSourcesViewModel.swift
//  LlamaChat
//
//  Created by Alex Rozanski on 30/03/2023.
//

import Foundation
import Combine
import AppModel
import DataModel

public class ChatListViewModel: ObservableObject {
  private let chatSourcesModel: ChatSourcesModel
  private weak var mainChatViewModel: MainChatViewModel?

  @Published private(set) var items: [ChatListItemViewModel]
  @Published private(set) var selectedSourceId: String?

  private var subscriptions = Set<AnyCancellable>()

  init(chatSourcesModel: ChatSourcesModel, mainChatViewModel: MainChatViewModel) {
    self.chatSourcesModel = chatSourcesModel
    self.mainChatViewModel = mainChatViewModel

    items = []
    items = makeViewModels(from: chatSourcesModel.sources, in: self)

    chatSourcesModel.$sources
      .map { [weak self] newSources in
        guard let self else { return [] }
        return makeViewModels(from: newSources, in: self)
      }
      .assign(to: &$items)
    mainChatViewModel.$selectedSourceId
      .assign(to: &$selectedSourceId)
  }

  func selectSource(with id: String?) {
    mainChatViewModel?.selectedSourceId = id
  }

  func removeSource(_ source: ChatSource) {
    mainChatViewModel?.removeChatSource(source)
  }

  func itemViewModel(with sourceId: String?) -> ChatListItemViewModel? {
    guard let sourceId else { return nil }
    return items.first(where: { $0.id == sourceId })
  }

  func moveItems(fromOffsets offsets: IndexSet, toOffset destination: Int) {
    chatSourcesModel.moveSources(fromOffsets: offsets, toOffset: destination)
  }
}

private func makeViewModels(from sources: [ChatSource], in viewModel: ChatListViewModel) -> [ChatListItemViewModel] {
  return sources.map { ChatListItemViewModel(chatSource: $0, chatListViewModel: viewModel) }
}
